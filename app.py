import tensorflow as tf
from tensorflow.keras import layers, models

# Define a simple neural network model
def create_model(input_shape):
    model = models.Sequential()
    model.add(layers.InputLayer(input_shape=input_shape))
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(1, activation='sigmoid'))  # Assuming binary classification

    model.compile(optimizer='adam', 
                  loss='binary_crossentropy', 
                  metrics=['accuracy'])
    return model

# Example data
import numpy as np
X_train = np.random.rand(100, 10)  # 100 samples, 10 features each
y_train = np.random.randint(2, size=100)  # Binary labels

# Create and train the model
input_shape = (X_train.shape[1],)
model = create_model(input_shape)
model.fit(X_train, y_train, epochs=10, batch_size=8)

# Evaluate the model
X_test = np.random.rand(20, 10)  # 20 samples, 10 features each
y_test = np.random.randint(2, size=20)  # Binary labels
loss, accuracy = model.evaluate(X_test, y_test)
print(f'Test accuracy: {accuracy:.4f}')
