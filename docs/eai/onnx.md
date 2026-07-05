# ONNX

ONNX全称为OpenNeuralNetworkExchange, 可以理解为AI模型的一个通用中间格式, 由微软和Facebook等公司共同创立, 它提供了一种统一的中间表示(IR), 让不同框架训练出的AI模型能够相互转换并在不同的平台上运行. 这是因为, 在人工智能领域, 市面上有许多不同的深度学习框架, 如PyTorch, TensorFlow, MXNet等等. 过去, 如果使用PyTorch训练了一个模型, 但是想把它部署到专门的边缘计算设备或者使用TensorFlow的工具进行加速, 通常需要重写代码或者进行复杂的格式转换, ONNX解决了这个痛点, 它定义了一套通用的计算图和算子标准.  