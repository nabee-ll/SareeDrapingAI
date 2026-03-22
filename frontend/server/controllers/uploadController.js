export const uploadImage = (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Image file is required.' });
  }

  return res.status(200).json({
    message: 'Image uploaded successfully.',
    filename: req.file.filename,
    path: `/uploads/${req.file.filename}`,
  });
};