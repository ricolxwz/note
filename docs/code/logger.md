---
title: Logger
comments: true
---

```py
import os
import logging

def get_logger(out_dir):
    logger = logging.getLogger('Exp')
    logger.setLevel(logging.INFO)  # 设置只记录INFO级别以上的日志
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")  # 定义日志的格式, 包含时间戳, 日志级别和日志内容

    file_path = os.path.join(out_dir, "run.log")  # 设置日志文件的路径
    file_hdlr = logging.FileHandler(file_path)  # 创建一个文件处理器, 用于将日志输出到文件
    file_hdlr.setFormatter(formatter)  # 设置文件处理器的日志格式

    strm_hdlr = logging.StreamHandler(sys.stdout)  # 创建一个流处理器, 用于将日志输出到控制台
    strm_hdlr.setFormatter(formatter)  # 设置流处理器的日志格式

    logger.addHandler(file_hdlr)  # 将文件处理器添加到日志器
    logger.addHandler(strm_hdlr)  # 将流处理器添加到日志器
    return logger
```
