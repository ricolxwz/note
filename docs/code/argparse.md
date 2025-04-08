---
title: Argparse
comments: true
---

```py
import glob
import os
import argparse
from tqdm import tqdm

parser = argparse.ArgumentParser()
parser.add_argument('--input_audio_folder', type=str, required=True)
parser.add_argument('--input_recons_folder', type=str, required=True)
parser.add_argument('--output_folder', type=str, required=True)
args = parser.parse_args()
os.makedirs(args.output_folder, exist_ok=True)  # 如果不存在输出目录, 则自动创建
total_audio_fns = glob.glob(f'{args.input_audio_folder}/*.wav')  # 按照f'{args.input_audio_folder}/*.wav'这个模式去匹配args.input_audio_folder文件夹下所有后缀名为.wav的音频文件, 并将完整的路径存储到列表total_audio_fns中
for audio_fn in tqdm(total_audio_fns):  # tqdm会为循环提供一个进度条
    extract_audio_features(audio_fn, args.input_recons_folder, args.output_folder)  # 对于列表中的每个音频文件, 都会调用extract_audio_features(audio_fn, args.input_recons_folder, args.output_folder) 函数, 进行音频特征提取并将提取结果保存到指定的输出文件夹
```
