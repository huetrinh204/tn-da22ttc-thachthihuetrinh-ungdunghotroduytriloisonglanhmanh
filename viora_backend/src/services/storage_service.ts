import { v2 as cloudinary } from "cloudinary";
import dotenv from "dotenv";

dotenv.config();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

/**
 * Upload buffer lên Cloudinary, trả về public URL
 */
export async function uploadToFirebase(
  fileBuffer: Buffer,
  originalName: string,
  folder: string = "uploads"
): Promise<string> {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: `viora/${folder}`, resource_type: "image" },
      (error, result) => {
        if (error || !result) return reject(error || new Error("Upload failed"));
        resolve(result.secure_url);
      }
    );
    uploadStream.end(fileBuffer);
  });
}

/**
 * Xóa file trên Cloudinary theo URL
 */
export async function deleteFromFirebase(url: string): Promise<void> {
  try {
    // Extract public_id từ URL cloudinary
    // URL dạng: https://res.cloudinary.com/CLOUD/image/upload/v123/viora/folder/filename.jpg
    const match = url.match(/\/viora\/.+\/([^/.]+)/);
    if (!match) return;
    const parts = url.split("/upload/");
    if (parts.length < 2) return;
    const pathWithVersion = parts[1]; // vXXX/viora/folder/filename.ext
    const publicId = pathWithVersion.replace(/^v\d+\//, "").replace(/\.[^/.]+$/, "");
    await cloudinary.uploader.destroy(publicId);
  } catch (err) {
    console.error("[Storage] Delete failed:", err);
  }
}
