---
title: 自动驾驶
date: 2019-01-08 21:50:00
updated: 2019-01-08 23:26:20
tags: Deep Learning
mathjax: true
typora-root-url: ./autonomous-driving
---

## 前言

最近在看《梁实秋读书与做人》，开始感受到了时间的宝贵，究竟如何才能掌握尚未逝去的时光呢？同时也尝试了刷一刷 LeetCode，毕竟这是每一个计算机从业者的基本功，不能再浑浑噩噩了。论文还是没有结果，在一个博士的指导下投了 B 刊，也是不能松懈，继续折腾吧！正好自己又有了一点小想法，可是为什么我的想法总是这么难实现呢？每一篇博客的前言都是被用来吐槽的，吐槽最近的生活与科研。空闲之余继续学习深度学习，这一节的内容是使用 YOLO 算法实现“自动驾驶”，其实是对摄像头拍摄的视频中的每一帧进行目标检测。

<!-- more -->

## 目标检测

这部分内容属于自动驾驶的一个模块，即车辆检测。通常自动驾驶需要给汽车安装一个摄像头，对前方路况进行拍摄，我们需要检测前方有无车辆以及车辆的位置信息，以供其它模块避开车辆。

![](box_label.png)

这里使用 YOLO 算法进行目标检测，一共有 80 个类别，即 $c$ 的取值为 $[1, 80]$ 或者是一个 80 维的独热向量，这两种表示在实验中都会使用，哪个方便用哪个。由于 YOLO 训练比较耗时，因此主要是了解 YOLO 算法的原理，最后实验会提供预训练好的模型。

## YOLO

YOLO (You Only Look Once) 算法在目标检测领域比较受欢迎，因为它的准确率比较高而且可以做到实时检测。这个算法只需要前向传播一次即可做出预测，在非极大值抑制后即可输出识别的目标和其位置信息。而前面介绍的 RCNN 系列算法则是需要先提取图像的感兴趣区域，再对这些区域进行分析，即需要“看”两次。

### 模型

* 输入：一个批次的三通道图像，其 shape 为 $(m, 608, 608, 3)$
* 输出：一个列表，列表中每个元素为一个 6 维向量 $(p_c, b_x, b_y, b_h, b_w, c)$；如果使用独热向量则是 85 维向量。

实验使用 5 个锚框，因此 YOLO 的结构为：IMAGE (m, 608, 608, 3) -> DEEP CNN -> ENCODING (m, 19, 19, 5, 85)，如下图所示：

![](architecture.png)

如果目标的中心在网格中，该网格就需要检测到该目标。由于使用了 5 个锚框，所以输出的 $19\times 19$ 网格中的每一个网格对应 5 个边界框，即输出的维度为 $(19, 19, 5, 85)$。将最后两个维度拉平得 $(19, 19, 425)$，如下图所示：

![](flatten.png)

对于网格中的每一个锚框，我们需要计算其中分类为每一个类别的概率，如下图所示：

![](probability_extraction.png)

图中 $p_c$ 为包含待检测目标的概率，$c_n$ 为属于第 $n$ 个类别的概率。因此 $p_cc_n$ 为锚框中包含第 $n$ 类目标的概率，最后取概率最大的一类作为该锚框的预测结果。由于一个网格对应 5 个锚框，最后再对这 5 个锚框的输出取最大值作为该网格的预测结果，即一个网格只保留一个锚框，该锚框对应一个类别的物体。有两种方法可以对算法进行可视化：对网格上色和绘制出每个网格对应的边界框。两种方式如下图所示：

![](proba_anchor.png)

即使取了最大值，但是输出的边界框还是很多。因此还可以对其进行过滤：

* 去除得分比较低的边界框（阈值过滤），得分低表示边界框不敢肯定其中检测到的目标
* 对于重叠内容比较多的边界框，只保留其中一个（非极大值抑制）

### 阈值过滤

设定阈值，过滤掉得分低于阈值的边界框。模型输出的维度为 $19\times 19\times 5\times 85$，每个 85 维的向量对应一个边界框，因此可以将模型的输出分为以下三部分：

* `box_confidence`: 维度为 $(19 \times 19, 5, 1)$ 的张量，对应所有边界框的 $p_c$
* `boxes`: 维度为 $(19 \times 19, 5, 4)$ 的张量，对应所有边界框的位置信息 $(b_x, b_y, b_h, b_w)$
* `box_class_probs`:  维度为 $(19 \times 19, 5, 80)$ 的张量，对应检测到的目标的类别的概率 $(c_1, c_2, ... c_{80})$

实现阈值过滤包含以下四个步骤：

1. 计算每个边界框包含的具体类别目标的概率 $p_cc_n$

   ``` python
   a = np.random.randn(19*19, 5, 1)
   b = np.random.randn(19*19, 5, 80)
   c = a * b # shape of c will be (19*19, 5, 80)
   ```

2. 对于每一个边界框，找到最大的得分 `box_class_scores` 与其对应类别的索引 `box_classes`

3. 根据阈值创建 mask 矩阵。如 `([0.9, 0.3, 0.4, 0.5, 0.1] < 0.4` 返回 `[False, True, False, False, True]`

4. 将 mask 矩阵应用到 `box_class_scores` 和 `box_classes` 中即可过滤出超过阈值的边界框

``` python
def yolo_filter_boxes(box_confidence, boxes, box_class_probs, threshold = .6):
    # Step 1: Compute box scores
    box_scores = np.multiply(box_confidence, box_class_probs)
    
    # Step 2: Find the box_classes thanks to the max box_scores, keep track of the corresponding score
    box_classes = K.argmax(box_scores, axis=-1)
    box_class_scores = K.max(box_scores, axis=-1)
    
    # Step 3: Create a filtering mask based on "box_class_scores" by using "threshold". The mask should have the
    # same dimension as box_class_scores, and be True for the boxes you want to keep (with probability >= threshold)
    filtering_mask = K.greater_equal(box_class_scores, threshold)
    
    # Step 4: Apply the mask to scores, boxes and classes
    scores = tf.boolean_mask(box_class_scores, filtering_mask)
    boxes = tf.boolean_mask(boxes, filtering_mask)
    classes = tf.boolean_mask(box_classes, filtering_mask)
    
    return scores, boxes, classes
```

### 非极大值抑制

阈值过滤后，还是会有很多边界框。它们框住同一个目标，因此 $p_cc_n$ 都会大于阈值，我们可以使用非极大值抑制来保留一个边界框，如下图所示：

![](non-max-suppression.png)

上图中模型预测出三个车，但是属于同一辆车，非极大值抑制可以保留最准确的一个边界框，即概率最大的一个。非极大值抑制中有一个很重要的概念叫**交并比 IoU**(Intersection over Union)，其原理如下图所示：

![](iou.png)

实验给定的边界框位置信息为左上角和右下角：(x1, y1, x2, y2)。即边界框的高为 (y2 - y1)，宽为 (x2 - x1)；图像的左上角为 (0, 0)，右上角为 (1, 0)，右下角为 (1, 1)。给定两个边界框，还需要找到交并后的坐标：

* `xi1`: 两个边界框 x1 的最大值
*  `yi1`: 两个边界框 y1 的最大值
* `xi2`: 两个边界框 x2 的最小值
* `yi2`: 两个边界框 y2 的最小值

``` python
def iou(box1, box2):
    # Calculate the (y1, x1, y2, x2) coordinates of the intersection of box1 and box2. Calculate its Area.
    xi1 = max(box1[0], box2[0])
    yi1 = max(box1[1], box2[1])
    xi2 = min(box1[2], box2[2])
    yi2 = min(box1[3], box2[3])
    inter_area = (xi2 - xi1)*(yi2 - yi1)

    # Calculate the Union area by using Formula: Union(A,B) = A + B - Inter(A,B)
    box1_area = (box1[3] - box1[1])*(box1[2]- box1[0])
    box2_area = (box2[3] - box2[1])*(box2[2]- box2[0])
    union_area = (box1_area + box2_area) - inter_area
    
    # compute the IoU
    iou = inter_area / union_area

    return iou
```

实现非极大值抑制分为三个步骤：

1. 将所有边界框按照得分排序，选择最高分的边界框 

2. 遍历其余的边界框，计算得分最高的边界框与这些边界框的交并比。如果交并比大于阈值 `iou_threshold`，则删除这些边界框

3. 迭代以上过程，直到处理完毕所有的边界框


Tensorflow 内置函数实现了非极大值抑制，代码如下所示：

``` python
def yolo_non_max_suppression(scores, boxes, classes, max_boxes = 10, iou_threshold = 0.5):
    max_boxes_tensor = K.variable(max_boxes, dtype='int32')     # tensor to be used in tf.image.non_max_suppression()
    K.get_session().run(tf.variables_initializer([max_boxes_tensor])) # initialize variable max_boxes_tensor
    
    # Use tf.image.non_max_suppression() to get the list of indices corresponding to boxes you keep
    nms_indices = tf.image.non_max_suppression(boxes, scores, max_boxes_tensor, iou_threshold=iou_threshold)

    # Use K.gather() to select only nms_indices from scores, boxes and classes
    scores = K.gather(scores, nms_indices)
    boxes = K.gather(boxes, nms_indices)
    classes = K.gather(classes, nms_indices)
    
    return scores, boxes, classes
```

### 合并过滤器

将以上两种过滤器合并为 `yolo_filter_boxes`；深度 CNN 输出的 $19\times 19\times 5\times 85$ 维向量，即 YOLO 的编码 `yolo_outputs`。由于过滤器需要的位置信息不同，需要将 (x, y, w, h) 转化为 (x1, y1, x2, y2)。如果测试集的图像尺寸与训练集不一致，例需要将其扩展到图像大小的测试集上，例如图像大小为 (720, 1280) 。实验提供这些功能的接口，代码如下所示：

``` python
def yolo_eval(yolo_outputs, image_shape = (720., 1280.), max_boxes=10, score_threshold=.6, iou_threshold=.5):
    # Retrieve outputs of the YOLO model (≈1 line)
    box_confidence, box_xy, box_wh, box_class_probs = yolo_outputs

    # Convert boxes to be ready for filtering functions 
    boxes = yolo_boxes_to_corners(box_xy, box_wh)

    # Use one of the functions you've implemented to perform Score-filtering with a threshold of score_threshold (≈1 line)
    scores, boxes, classes = yolo_filter_boxes(box_confidence, boxes, box_class_probs, threshold = score_threshold)
    
    # Scale boxes back to original image shape.
    boxes = scale_boxes(boxes, image_shape)

    # Use one of the functions you've implemented to perform Non-max suppression with a threshold of iou_threshold (≈1 line)
    scores, boxes, classes = yolo_non_max_suppression(scores, boxes, classes, max_boxes = max_boxes, iou_threshold = iou_threshold)
    
    return scores, boxes, classes
```

## 测试

在图像大小为 (720, 1280) 的测试集上测试预训练的模型，由于需要检测 80 种类别并且使用 5 个锚框，因此需要先载入这些信息。

``` python
sess = K.get_session()
class_names = read_classes("model_data/coco_classes.txt")
anchors = read_anchors("model_data/yolo_anchors.txt")
image_shape = (720., 1280.)

yolo_model = load_model("model_data/yolo.h5")
```

该模型的输出维度为 (m, 608, 608, 3))，输出维度为 (m, 19, 19, 5, 85)。将输出转化为过滤器的输入所需的维度，继而对边界框进行过滤：

``` python
yolo_outputs = yolo_head(yolo_model.output, anchors, len(class_names))
scores, boxes, classes = yolo_eval(yolo_outputs, image_shape)
```

### 运行图

目前为止，我们已经创建了一个 (sess) 图，主要包含以下三部分内容：

1. `yolo_model`: 输入为 yolo_model.input，输出为 yolo_model.output
2. `yolo_head`: 输入为 yolo_model.output，输出为 yolo_outputs
3. `yolo_eval`: 过滤函数，输入为 yolo_outputs，输出为预测结果 scores, boxes 和 classes

``` python
def predict(sess, image_file):
    # Preprocess your image
    image, image_data = preprocess_image("images/" + image_file, model_image_size = (608, 608))

    # Run the session with the correct tensors and choose the correct placeholders in the feed_dict.
    # You'll need to use feed_dict={yolo_model.input: ... , K.learning_phase(): 0})
    out_scores, out_boxes, out_classes = sess.run([scores, boxes, classes], feed_dict={yolo_model.input: image_data, K.learning_phase(): 0})

    # Print predictions info
    print('Found {} boxes for {}'.format(len(out_boxes), image_file))
    # Generate colors for drawing bounding boxes.
    colors = generate_colors(class_names)
    # Draw bounding boxes on the image file
    draw_boxes(image, out_scores, out_boxes, out_classes, class_names, colors)
    # Save the predicted bounding box on the image
    image.save(os.path.join("out", image_file), quality=90)
    # Display the results in the notebook
    output_image = scipy.misc.imread(os.path.join("out", image_file))
    imshow(output_image)

    return out_scores, out_boxes, out_classes
```

`preprocess_image` 函数返回的 image 用于绘制边界框。在测试图像种运行结果如下所示：

``` python
out_scores, out_boxes, out_classes = predict(sess, "test.jpg")
```

``` bash
Found 7 boxes for test.jpg
car 0.60 (925, 285) (1045, 374)
car 0.66 (706, 279) (786, 350)
bus 0.67 (5, 266) (220, 407)
car 0.70 (947, 324) (1280, 705)
car 0.74 (159, 303) (346, 440)
car 0.80 (761, 282) (942, 412)
car 0.89 (367, 300) (745, 648)
```

![](output.png)

## 总结

YOLO 是目前目标检测领域最快最准确的算法，其直接在整张图像上运行 CNN 网络，输出 $19\times 19\times 5\times 85$ 的向量。这个输出的编码可以看成是一个 $19\times 19$ 的网格，每个网格对应 5 个边界框。然后使用非极大值抑制对边界框进行过滤，得到最后的结果。这种直接对图像运行 CNN 得到输出的形式，只需要一趟即可得到结果，不像 RCNN 需要先提取感兴趣的区域。

## 参考文献

1. 吴恩达. DeepLearning. 
2. Joseph Redmon, Santosh Divvala, Ross Girshick, Ali Farhadi - [You Only Look Once: Unified, Real-Time Object Detection](https://arxiv.org/abs/1506.02640) (2015)
3. Joseph Redmon, Ali Farhadi - [YOLO9000: Better, Faster, Stronger](https://arxiv.org/abs/1612.08242) (2016)