import numpy as np
import tensorflow as tf
from PIL import Image



def preprocess_image(image_path):
    """ Load and preprocess image for TFLite model """
    image = Image.open(image_path).resize((299, 299))  # Updated to 299x299
    image = np.array(image, dtype=np.float32) / 255.0  # Normalize (0 to 1)
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    return image

def classify_image(image_path,category,type):

    label=type+"_"+category


    interpreter = tf.lite.Interpreter(model_path=f"./models/{label}.tflite")
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    ensem_label = {
        'apple_leaf': ['apple_scab', 'apple_blackrot', 'apple_Cedar_rust', 'apple_healthy'],
        'apple_fruit': ['apple_blotch', 'apple_healthy', 'apple_blackrot', 'apple_scab'],
        'turmeric_leaf':['turmeric_leaf_blotch','tumeric_healthy','turmeric_leaf_spot']
    }


    """ Classify image using TFLite model """
    input_data = preprocess_image(image_path)

    # Set input tensor
    interpreter.set_tensor(input_details[0]['index'], input_data)

    # Run inference
    interpreter.invoke()

    # Get output tensor and find the predicted class
    output_data = interpreter.get_tensor(output_details[0]['index'])
    predicted_class = np.argmax(output_data)

    print(ensem_label[label],predicted_class)

    return ensem_label[label][predicted_class]

if __name__=="__main__":
        
    # Example: Classify an image
    image_path = "uploads/1000127480.jpg"  # Change to your image file
    result = classify_image(image_path)
    print(f"Predicted Class: {result}")
