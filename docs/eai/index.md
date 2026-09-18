---
title: 端侧AI学习路线
comments: true
---

# 端侧AI学习路线

目标职业定位：**Linux/C++端侧AI推理部署工程师**。

结合已有的智慧停车与 C++ 经历，以模型部署和推理性能优化为主线开展学习。

## 学习重点

| 方向 | 重点内容 |
| --- | --- |
| C++工程基础 | C++11/17、多线程、智能指针、CMake、gdb、perf |
| Linux基础 | 编译链接、动态库、进程线程、性能分析；暂时不用深入驱动和内核 |
| AI基础 | Tensor、CNN、Transformer基础、FP32/FP16/INT8、量化基本概念 |
| 模型部署链路 | PyTorch → ONNX → ONNX Runtime；后续按目标硬件学习 TensorRT 或 RKNN |
| 端侧硬件 | 后续学习 RK3588、Jetson，以及 ARM/NPU/GPU |
| 性能优化 | 延迟、FPS、内存占用、多线程 pipeline、zero-copy |

## 学习顺序

### 前3个月：基础部署

学习 Python/PyTorch 基础、OpenCV、YOLO 和 ONNX Runtime C++，跑通模型导出与 C++ 推理。

### 3～6个月：推理加速

学习 TensorRT、FP16/INT8、benchmark 和性能分析。

### 6～12个月：硬件部署

购买 RK3588 等开发板，学习 RKNN 部署，完成视频流 AI 项目。

## 个人项目：C++边缘车辆检测系统

```text
RTSP视频 → 解码 → YOLO推理（ONNX Runtime / RKNN / TensorRT）→ 车辆检测 → 结果输出
```

这个项目与已有的智慧停车和 C++ 经历相匹配，可以从 ONNX Runtime C++ 版本开始，再按目标硬件接入 TensorRT 或 RKNN。

## 暂缓深入的方向

暂时不要花大量时间学习 CUDA Kernel、Linux驱动、FPGA、MLIR、分布式训练，优先完成部署链路与项目实践。