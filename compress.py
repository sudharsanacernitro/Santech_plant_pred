import tensorflow as tf

# Load the TFLite model (use TFLite Interpreter)
interpreter = tf.lite.Interpreter(model_path="models/apple_fruit.tflite")

# Convert to a more optimized format
converter = tf.lite.TFLiteConverter.from_saved_model("models/apple_fruit.tflite")
converter.optimizations = [tf.lite.Optimize.DEFAULT]

compressed_model = converter.convert()

with open("models/apple_fruit_compressed.tflite", "wb") as f:
    f.write(compressed_model)

print("Model quantization complete! 🚀")
