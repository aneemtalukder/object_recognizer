binary = binary_image_generator('two_objects.pgm', 140);
figure, imshow(binary);
labels_out = sequential_labeler(binary);
figure, imagesc(labels_out);
database = object_parser(labels_out);

many_objects_binary = binary_image_generator('many_objects_1.pgm', 130);
many_labels = sequential_labeler(many_objects_binary);
overlays_out = object_recognizer(many_labels, database);