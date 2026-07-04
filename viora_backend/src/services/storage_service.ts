import * as admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";
import path from "path";

// Lấy storage bucket từ Firebase Admin (đã init trong fcm_push_service)
function getBucket() {
  const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;
  if (!storageBucket) throw new Error("FIREBASE_STORAGE_BUCKET not set");
  return admin.storage().bucket(storageBucket);
}

/**
 * Upload buffer lên Firebase Storage, trả về public URL
 * @param fileBuffer - nội dung file
 * @param originalName - tên file gốc (để lấy extension)
 * @param folder - thư mục trên Storage (vd: "avatars", "posts")
 */
export async function uploadToFirebase(
  fileBuffer: Buffer,
  originalName: string,
  folder: string = "uploads"
): Promise<string> {
  const ext = path.extname(originalName) || ".jpg";
  const filename = `${folder}/${uuidv4()}${ext}`;
  const bucket = getBucket();
  const file = bucket.file(filename);

  await file.save(fileBuffer, {
    metadata: {
      contentType: `image/${ext.replace(".", "")}`,
    },
    public: true,
  });

  // Trả về URL công khai
  return `https://storage.googleapis.com/${bucket.name}/${filename}`;
}

/**
 * Xóa file trên Firebase Storage theo URL
 */
export async function deleteFromFirebase(url: string): Promise<void> {
  try {
    const bucket = getBucket();
    const bucketName = bucket.name;
    // Extract path từ URL: https://storage.googleapis.com/BUCKET/PATH
    const prefix = `https://storage.googleapis.com/${bucketName}/`;
    if (!url.startsWith(prefix)) return;
    const filePath = url.replace(prefix, "");
    await bucket.file(filePath).delete();
  } catch (err) {
    console.error("[Storage] Delete failed:", err);
  }
}
