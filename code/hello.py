import numpy as np

x = np.array([3, 4, 2, 1])
y = np.array([3, 4, 2, 1]) * 2
z = np.dot(x, y)

print("Imported numpy: success!")
print("Simple math gives z = {z}".format(z = z))
