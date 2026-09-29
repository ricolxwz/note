# mkcc

```python
#!/usr/bin/env python3

import argparse
import json
import os
import re
import shlex
import subprocess
import sys
from collections import deque


SRC_EXT = (
    '.c',
    '.cc',
    '.cpp',
    '.cxx',
    '.C',
    '.cp',
)

HDR_EXT = (
    '.h',
    '.hh',
    '.hpp',
    '.hxx',
    '.inl',
)

CC_RE = re.compile(
    r'^(?:[a-zA-Z0-9_][a-zA-Z0-9_.-]*-)?'
    r'(?:gcc|g\+\+|clang|clang\+\+|cc|c\+\+)'
    r'(?:-\d+(?:\.\d+)*)?$'
)

ENTER_RE = re.compile(
    r"make\[\d+\]: Entering directory '(.+?)'"
)

LEAVE_RE = re.compile(
    r"make\[\d+\]: Leaving directory '(.+?)'"
)

INC_RE = re.compile(
    r'^\s*#\s*include\s*[<"]([^>"]+)[>"]',
    re.MULTILINE,
)

SKIP_DIR = {
    '.svn',
    '.git',
    'node_modules',
}


# ============================================================
# 通用辅助
# ============================================================

def split_semi(value):
    return [
        x.strip()
        for x in (value or '').split(';')
        if x.strip()
    ]


def normalize_include_path(path):
    path = path.strip()
    path = path.replace('\\', '/')
    path = re.sub(r'/+', '/', path)

    while path.startswith('./'):
        path = path[2:]

    return path


def normalize_map_path(path):
    if not path:
        return path

    return path.replace('\\', '/')


def normalize_fs_path(path):
    path = os.path.abspath(path)
    path = os.path.normpath(path)
    return os.path.normcase(path)


def path_parts(path):
    path = normalize_map_path(
        os.path.abspath(path)
    )

    return [
        p
        for p in path.split('/')
        if p
    ]


# ============================================================
# make dry-run
# ============================================================

def dry_run_parse(root, make_args):
    cmd = [
        'make',
        '-Bnwk',
        '-j32',
    ] + make_args

    print(
        f">> dry run:{' '.join(cmd)} (在{root})"
    )

    try:
        env = dict(
            os.environ,
            LC_ALL='C',
        )

        p = subprocess.run(
            cmd,
            cwd=root,
            capture_output=True,
            text=True,
            errors='replace',
            env=env,
        )

    except FileNotFoundError:
        print(
            ">> make不在PATH中, 跳过dry run"
        )
        return []

    except KeyboardInterrupt:
        sys.exit(1)

    entries = []

    cwd = root
    stack = []

    for raw in p.stdout.splitlines():

        m = ENTER_RE.search(raw)

        if m:
            stack.append(cwd)

            new_cwd = m.group(1)

            if os.path.isabs(new_cwd):
                cwd = new_cwd
            else:
                cwd = os.path.normpath(
                    os.path.join(
                        cwd,
                        new_cwd,
                    )
                )

            continue

        m = LEAVE_RE.search(raw)

        if m:
            if stack:
                cwd = stack.pop()

            continue

        s = raw.strip().strip('()').lstrip()

        while s[:1] in (
            '@',
            '+',
            '-',
        ):
            s = s[1:].lstrip()

        if not s:
            continue

        try:
            tokens = shlex.split(s)

        except ValueError:
            tokens = s.split()

        if not tokens:
            continue

        directory = cwd

        # 支持:
        #
        # cd xxx && g++ ...
        #
        if (
            tokens[0] == 'cd'
            and len(tokens) > 2
        ):

            target = tokens[1]

            if os.path.isabs(target):
                directory = os.path.normpath(
                    target
                )

            else:
                directory = os.path.normpath(
                    os.path.join(
                        cwd,
                        target,
                    )
                )

            tokens = tokens[2:]

        while (
            tokens
            and tokens[0] in (
                '&&',
                '||',
                ';',
            )
        ):
            tokens = tokens[1:]

        if not tokens:
            continue

        compiler = os.path.basename(
            tokens[0]
        )

        if not CC_RE.match(compiler):
            continue

        if '-c' not in tokens:
            continue

        source_index = next(
            (
                i
                for i, token in enumerate(tokens)
                if (
                    not token.startswith('-')
                    and token.endswith(SRC_EXT)
                )
            ),
            None,
        )

        if source_index is None:
            continue

        entries.append({
            'directory': directory,
            'arguments': list(tokens),
            'file': tokens[source_index],
        })

    status = (
        f"exit={p.returncode}"
        if p.returncode
        else 'ok'
    )

    print(
        f">> dry run结束({status}), "
        f"提取到{len(entries)}条编译命令"
    )

    return entries


# ============================================================
# 项目扫描
# ============================================================

def scan_tree(roots):
    srcs = []
    headers = {}

    seen_roots = set()

    for root in roots:

        root = os.path.abspath(root)

        root_key = normalize_fs_path(root)

        if root_key in seen_roots:
            continue

        seen_roots.add(root_key)

        if not os.path.isdir(root):

            print(
                f">> 警告:扫描目录不存在:{root}"
            )

            continue

        for (
            dirpath,
            dirnames,
            filenames,
        ) in os.walk(root):

            dirnames[:] = [
                d
                for d in dirnames
                if d not in SKIP_DIR
            ]

            for filename in filenames:

                full_path = os.path.join(
                    dirpath,
                    filename,
                )

                if filename.endswith(SRC_EXT):

                    srcs.append(
                        os.path.abspath(
                            full_path
                        )
                    )

                elif filename.endswith(HDR_EXT):

                    headers.setdefault(
                        filename,
                        [],
                    ).append(
                        os.path.abspath(
                            full_path
                        )
                    )

    srcs.sort()

    for values in headers.values():
        values.sort()

    return srcs, headers


# ============================================================
# include解析
# ============================================================

def resolve_include(
    current_file,
    include_path,
    headers,
):
    include_path = normalize_include_path(
        include_path
    )

    if not include_path:
        return None

    current_dir = os.path.dirname(
        os.path.abspath(current_file)
    )

    # --------------------------------------------------------
    # 1. 相对于当前文件目录
    # --------------------------------------------------------

    direct = os.path.normpath(
        os.path.join(
            current_dir,
            *include_path.split('/'),
        )
    )

    if os.path.isfile(direct):
        return os.path.abspath(direct)

    # --------------------------------------------------------
    # 2. 根据完整include路径后缀匹配
    #
    # Manager/Event.h
    #
    # 匹配:
    #
    # /xxx/Include/Manager/Event.h
    # --------------------------------------------------------

    include_parts = [
        x
        for x in include_path.split('/')
        if x
    ]

    if not include_parts:
        return None

    basename = include_parts[-1]

    candidates = headers.get(
        basename,
        [],
    )

    include_parts_lower = [
        x.lower()
        for x in include_parts
    ]

    matched = []

    for candidate in candidates:

        candidate_parts = path_parts(
            candidate
        )

        if (
            len(candidate_parts)
            < len(include_parts)
        ):
            continue

        suffix = candidate_parts[
            -len(include_parts):
        ]

        if [
            x.lower()
            for x in suffix
        ] == include_parts_lower:

            matched.append(candidate)

    if matched:

        matched.sort(
            key=lambda p: (
                len(path_parts(p)),
                normalize_map_path(
                    p
                ).lower(),
            )
        )

        return os.path.abspath(
            matched[0]
        )

    # --------------------------------------------------------
    # 3. basename fallback
    #
    # #include "Event.h"
    # --------------------------------------------------------

    if (
        len(include_parts) == 1
        and candidates
    ):
        return os.path.abspath(
            candidates[0]
        )

    return None


def infer_include_root(
    header_path,
    include_path,
):
    """
    例如:

        实际文件:
            /xxx/Include/Manager/Event.h

        include:
            Manager/Event.h

        返回:
            /xxx/Include


        实际文件:
            /xxx/Include/Manager/Event.h

        include:
            Event.h

        返回:
            /xxx/Include/Manager
    """

    include_path = normalize_include_path(
        include_path
    )

    include_parts = [
        x
        for x in include_path.split('/')
        if x
    ]

    if not include_parts:
        return None

    header_path = os.path.abspath(
        header_path
    )

    header_parts = path_parts(
        header_path
    )

    if (
        len(header_parts)
        < len(include_parts)
    ):
        return None

    suffix = header_parts[
        -len(include_parts):
    ]

    if [
        x.lower()
        for x in suffix
    ] != [
        x.lower()
        for x in include_parts
    ]:
        return None

    root = header_path

    for _ in include_parts:
        root = os.path.dirname(root)

    return os.path.normpath(
        root
    )


def collect_include_tree(
    src,
    headers,
):
    """
    递归扫描:

        cpp
          -> h
            -> h
              -> h
    """

    result = []

    visited = set()

    queue = deque([
        os.path.abspath(src)
    ])

    while queue:

        current = queue.popleft()

        current_key = normalize_fs_path(
            current
        )

        if current_key in visited:
            continue

        visited.add(
            current_key
        )

        try:

            with open(
                current,
                'r',
                encoding='utf-8',
                errors='ignore',
            ) as fp:

                text = fp.read()

        except OSError:
            continue

        for include_path in INC_RE.findall(
            text
        ):

            include_path = (
                normalize_include_path(
                    include_path
                )
            )

            header = resolve_include(
                current,
                include_path,
                headers,
            )

            # 系统头文件不在项目扫描结果中时,
            # 直接忽略.
            if not header:
                continue

            result.append(
                (
                    header,
                    include_path,
                )
            )

            header_key = normalize_fs_path(
                header
            )

            if header_key not in visited:

                queue.append(
                    header
                )

    return result


def include_dirs_for(
    src,
    headers,
):
    dirs = []
    seen = set()

    include_tree = collect_include_tree(
        src,
        headers,
    )

    for (
        header,
        include_path,
    ) in include_tree:

        include_root = infer_include_root(
            header,
            include_path,
        )

        if not include_root:
            continue

        key = normalize_fs_path(
            include_root
        )

        if key in seen:
            continue

        seen.add(key)

        dirs.append(
            os.path.normpath(
                include_root
            )
        )

    return dirs


def modify_entries(
    entries,
    headers,
):
    print(
        ">> 开始递归分析include依赖..."
    )

    total = len(entries)

    for index, entry in enumerate(
        entries,
        start=1,
    ):

        src = entry['file']

        if not os.path.isabs(src):

            src = os.path.join(
                entry['directory'],
                src,
            )

        src = os.path.abspath(
            src
        )

        include_dirs = include_dirs_for(
            src,
            headers,
        )

        existing = set(
            entry['arguments']
        )

        for directory in include_dirs:

            flag = (
                f'-I{directory}'
            )

            if flag in existing:
                continue

            entry['arguments'].append(
                flag
            )

            existing.add(
                flag
            )

        if (
            index % 100 == 0
            or index == total
        ):

            print(
                f">> include分析:"
                f"{index}/{total}"
            )


def fallback_entries(
    srcs,
    headers,
    root,
):
    """
    默认模式.
    不执行make.
    """

    entries = []

    total = len(srcs)

    print(
        ">> 开始源码扫描生成编译数据库..."
    )

    for index, src in enumerate(
        srcs,
        start=1,
    ):

        rel = os.path.relpath(
            src,
            root,
        )

        args = [
            'g++',
            '-c',
            rel,
        ]

        for directory in include_dirs_for(
            src,
            headers,
        ):

            args.append(
                f'-I{directory}'
            )

        entries.append({
            'directory': root,
            'arguments': args,
            'file': rel,
        })

        if (
            index % 100 == 0
            or index == total
        ):

            print(
                f">> 源码扫描:"
                f"{index}/{total}"
            )

    return entries


# ============================================================
# Path Map
# ============================================================

def remap_path(
    path,
    path_map,
):
    if not path:
        return path

    normalized = normalize_map_path(
        path
    )

    for old, new in path_map:

        old_norm = normalize_map_path(
            old
        ).rstrip('/')

        new_norm = normalize_map_path(
            new
        ).rstrip('/')

        if not old_norm:
            continue

        if normalized == old_norm:
            return new_norm

        prefix = (
            old_norm
            + '/'
        )

        if normalized.startswith(
            prefix
        ):

            suffix = normalized[
                len(old_norm):
            ]

            return (
                new_norm
                + suffix
            )

    return path


def remap_single_argument(
    arg,
    path_map,
):
    # 长前缀必须放在-I前面.
    prefixes = (
        '-isystem',
        '-iquote',
        '-idirafter',
        '-include',
        '-imacros',
        '-I',
    )

    for prefix in prefixes:

        if (
            arg.startswith(prefix)
            and len(arg) > len(prefix)
        ):

            path = arg[
                len(prefix):
            ]

            mapped = remap_path(
                path,
                path_map,
            )

            return (
                prefix
                + mapped
            )

    return remap_path(
        arg,
        path_map,
    )


def remap_arguments(
    arguments,
    path_map,
):
    result = []

    path_options = {
        '-I',
        '-isystem',
        '-iquote',
        '-idirafter',
        '-include',
        '-imacros',
    }

    i = 0

    while i < len(arguments):

        arg = arguments[i]

        if (
            arg in path_options
            and i + 1 < len(arguments)
        ):

            result.append(
                arg
            )

            result.append(
                remap_path(
                    arguments[i + 1],
                    path_map,
                )
            )

            i += 2
            continue

        result.append(
            remap_single_argument(
                arg,
                path_map,
            )
        )

        i += 1

    return result


def apply_path_map(
    entries,
    extra_flags,
    path_map,
):
    for entry in entries:

        entry['directory'] = remap_path(
            entry['directory'],
            path_map,
        )

        entry['file'] = remap_path(
            entry['file'],
            path_map,
        )

        entry['arguments'] = remap_arguments(
            entry['arguments'],
            path_map,
        )

    extra_flags = remap_arguments(
        extra_flags,
        path_map,
    )

    return extra_flags


def verify_path_map(
    entries,
    extra_flags,
    path_map,
):
    for old, new in path_map:

        old_norm = normalize_map_path(
            old
        ).rstrip('/')

        leftovers = []

        for entry in entries:

            directory = normalize_map_path(
                entry.get(
                    'directory',
                    '',
                )
            )

            if old_norm in directory:

                leftovers.append(
                    (
                        entry.get(
                            'file',
                            '',
                        ),
                        'directory',
                        entry['directory'],
                    )
                )

            file_path = normalize_map_path(
                entry.get(
                    'file',
                    '',
                )
            )

            if old_norm in file_path:

                leftovers.append(
                    (
                        entry.get(
                            'file',
                            '',
                        ),
                        'file',
                        entry['file'],
                    )
                )

            for argument in entry.get(
                'arguments',
                [],
            ):

                if (
                    old_norm
                    in normalize_map_path(
                        argument
                    )
                ):

                    leftovers.append(
                        (
                            entry.get(
                                'file',
                                '',
                            ),
                            'argument',
                            argument,
                        )
                    )

            if len(leftovers) >= 20:
                break

        for flag in extra_flags:

            if (
                old_norm
                in normalize_map_path(
                    flag
                )
            ):

                leftovers.append(
                    (
                        '<extra_flags>',
                        'argument',
                        flag,
                    )
                )

        if not leftovers:

            print(
                f">> 路径映射验证成功:"
                f"{old} -> {new}, 旧路径已无残留"
            )

            continue

        print(
            f">> 警告:路径映射后仍存在'{old}'"
        )

        for (
            source,
            kind,
            value,
        ) in leftovers[:20]:

            print(
                f"   [{source}] "
                f"{kind}:{value}"
            )


# ============================================================
# Main
# ============================================================

def main():
    parser = argparse.ArgumentParser(
        description=(
            '生成compile_commands.json'
        )
    )

    parser.add_argument(
        'dir',
        nargs='?',
        help=(
            '项目根目录, 缺省为当前目录'
        ),
    )

    parser.add_argument(
        '--dir',
        dest='dir_opt',
        help=(
            '同上, 兼容rws-build参数形式'
        ),
    )

    parser.add_argument(
        '--include-dirs',
        default='',
        help=(
            "include目录/扫描根, 分号分隔."
            "'#目录'表示扫描根, "
            "不带#表示字面-I."
        ),
    )

    parser.add_argument(
        '--defines',
        default='',
        help=(
            "宏定义, 分号分隔."
            "'#目录'表示扫描根, "
            "不带#表示字面-D."
        ),
    )

    parser.add_argument(
        '--make-args',
        default=os.environ.get(
            'MKCC_MAKE_ARGS',
            '',
        ),
        help=(
            'dry-run模式下附加的make参数.'
        ),
    )

    # 默认源码扫描.
    # 只有显式指定--dry-run才执行make.
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help=(
            '启用make dry run提取真实编译命令.'
            '默认不执行make, 直接源码扫描.'
        ),
    )

    parser.add_argument(
        '--clangd',
        action='store_true',
        help=(
            '同时生成.clangd.'
        ),
    )

    parser.add_argument(
        '--path-map',
        default='',
        help=(
            '路径替换, "旧=新"分号分隔.'
            '例如"/home/610184=Z:"'
        ),
    )

    args = parser.parse_args()

    # ========================================================
    # 项目根
    # ========================================================

    root = (
        args.dir_opt
        or args.dir
    )

    root = (
        os.path.abspath(root)
        if root
        else os.getcwd()
    )

    print(
        f">> 项目根:{root}"
    )

    # ========================================================
    # 扫描根
    # ========================================================

    roots = []
    extra_flags = []

    for item in split_semi(
        args.include_dirs
    ):

        if item.startswith('#'):

            scan_root = item[1:]

            if not os.path.isabs(
                scan_root
            ):

                scan_root = os.path.join(
                    root,
                    scan_root,
                )

            roots.append(
                os.path.abspath(
                    scan_root
                )
            )

        else:

            extra_flags.append(
                f'-I{item}'
            )

    for item in split_semi(
        args.defines
    ):

        if item.startswith('#'):

            scan_root = item[1:]

            if not os.path.isabs(
                scan_root
            ):

                scan_root = os.path.join(
                    root,
                    scan_root,
                )

            roots.append(
                os.path.abspath(
                    scan_root
                )
            )

        else:

            extra_flags.append(
                f'-D{item}'
            )

    roots.insert(
        0,
        root,
    )

    unique_roots = []
    seen_roots = set()

    for scan_root in roots:

        key = normalize_fs_path(
            scan_root
        )

        if key in seen_roots:
            continue

        seen_roots.add(
            key
        )

        unique_roots.append(
            scan_root
        )

    roots = unique_roots

    print(
        ">> 扫描根:"
        + ', '.join(roots)
    )

    # ========================================================
    # 扫描源码
    # ========================================================

    srcs, headers = scan_tree(
        roots
    )

    header_count = sum(
        len(values)
        for values in headers.values()
    )

    print(
        f">> 扫描到源文件{len(srcs)}个, "
        f"头文件{header_count}个"
    )

    # ========================================================
    # 生成编译数据库
    # ========================================================

    if args.dry_run:

        print(
            ">> 模式:make dry run"
        )

        make_args = shlex.split(
            args.make_args
        )

        entries = dry_run_parse(
            root,
            make_args,
        )

        if entries:

            modify_entries(
                entries,
                headers,
            )

        else:

            print(
                ">> dry run没有产生编译命令, "
                "自动回退到源码扫描"
            )

            entries = fallback_entries(
                srcs,
                headers,
                root,
            )

    else:

        print(
            ">> 模式:源码扫描"
        )

        print(
            ">> 未指定--dry-run, 不执行make"
        )

        entries = fallback_entries(
            srcs,
            headers,
            root,
        )

    if not entries:

        sys.exit(
            ">> 失败:没有产生任何编译命令"
        )

    # ========================================================
    # Path Map
    # ========================================================

    path_map = []

    for item in split_semi(
        args.path_map
    ):

        if '=' not in item:

            sys.exit(
                f">> --path-map项'{item}'缺少'=', "
                f"格式应为旧路径=新路径"
            )

        old, new = item.split(
            '=',
            1,
        )

        old = normalize_map_path(
            old.strip()
        ).rstrip('/')

        new = normalize_map_path(
            new.strip()
        ).rstrip('/')

        if not old:

            sys.exit(
                ">> --path-map旧路径不能为空"
            )

        path_map.append(
            (
                old,
                new,
            )
        )

    if path_map:

        print(
            ">> 路径替换:"
            + ', '.join(
                f"{old} -> {new}"
                for old, new in path_map
            )
        )

        extra_flags = apply_path_map(
            entries,
            extra_flags,
            path_map,
        )

        verify_path_map(
            entries,
            extra_flags,
            path_map,
        )

    # ========================================================
    # 用户额外-I/-D
    # ========================================================

    for entry in entries:

        existing = set(
            entry['arguments']
        )

        for flag in extra_flags:

            if flag in existing:
                continue

            entry['arguments'].append(
                flag
            )

            existing.add(
                flag
            )

    # ========================================================
    # .clangd
    # ========================================================

    if args.clangd:

        clangd_out = os.path.join(
            root,
            '.clangd',
        )

        clangd_flags = list(
            extra_flags
        )

        if clangd_flags:

            lines = [
                'CompileFlags:',
                '  Add:',
            ]

            for flag in clangd_flags:

                escaped = flag.replace(
                    "'",
                    "''",
                )

                lines.append(
                    f"    - '{escaped}'"
                )

        else:

            lines = [
                'CompileFlags:',
                '  Add: []',
            ]

        with open(
            clangd_out,
            'w',
            encoding='utf-8',
        ) as fp:

            fp.write(
                '\n'.join(lines)
                + '\n'
            )

        print(
            f">> 完成:{clangd_out}"
        )

    # ========================================================
    # 写compile_commands.json
    #
    # 输出文件仍然写到Linux真实root.
    #
    # JSON内部路径可以通过--path-map映射为Windows路径.
    # ========================================================

    out = os.path.join(
        root,
        'compile_commands.json',
    )

    with open(
        out,
        'w',
        encoding='utf-8',
    ) as fp:

        json.dump(
            entries,
            fp,
            indent=2,
            ensure_ascii=False,
        )

        fp.write('\n')

    print(
        f">> 完成:{out}, "
        f"{len(entries)}条"
    )


if __name__ == '__main__':
    main()
```
