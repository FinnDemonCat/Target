#include <raylib.h>
#include <stdlib.h>

#define BRIDGE_EXPORT __declspec(dllexport)

BRIDGE_EXPORT void FreeVector2(void* pointer) {
	if (pointer == NULL) return;

	Vector2* vector2Ptr = (Vector2*)pointer;
	free(vector2Ptr);
}

BRIDGE_EXPORT void FreeVector3(void* pointer) {
	if (pointer == NULL) return;

	Vector3* vector3Ptr = (Vector3*)pointer;
	free(vector3Ptr);
}

BRIDGE_EXPORT void FreeVector4(void* pointer) {
	if (pointer == NULL) return;

	Vector4* vector4Ptr = (Vector4*)pointer;
	free(vector4Ptr);
}

// BRIDGE_EXPORT void FreeQuaternion(void* pointer) {
// 	if (pointer == NULL) return;

// 	Quaternion* quaternionPtr = (Quaternion*)pointer;
// 	free(*quaternionPtr);
// 	*quaternionPtr = NULL;
// }

BRIDGE_EXPORT void FreeMatrix(void* pointer) {
	if (pointer == NULL) return;

	Matrix* matrixPtr = (Matrix*)pointer;
	free(matrixPtr);
}

BRIDGE_EXPORT void FreeColor(void* pointer) {
	if (pointer == NULL) return;

	Color* colorPtr = (Color*)pointer;
	free(colorPtr);
}

BRIDGE_EXPORT void FreeRectangle(void* pointer) {
	if (pointer == NULL) return;

	Rectangle* rectanglePtr = (Rectangle*)pointer;
	free(rectanglePtr);
}

BRIDGE_EXPORT void FreeImage(void* pointer) {
	if (pointer == NULL) return;

	Image* imagePtr = (Image*)pointer;

	Image image = *imagePtr;
	UnloadImage(image);
	free(imagePtr);
}

BRIDGE_EXPORT void FreeTexture(void* pointer) {
	if (pointer == NULL) return;

	Texture* texturePtr = (Texture*)pointer;

	Texture texture = *texturePtr;
	UnloadTexture(texture);
	free(texturePtr);
}

BRIDGE_EXPORT void FreeRenderTexture(void* pointer) {
	if (pointer == NULL) return;

	RenderTexture* renderTexturePtr = (RenderTexture*)pointer;

	RenderTexture renderTexture = *renderTexturePtr;
	UnloadRenderTexture(renderTexture);
	free(renderTexturePtr);
}

BRIDGE_EXPORT void FreeNPatchInfo(void* pointer) {
	if (pointer == NULL) return;

	NPatchInfo* nPatchInfoPtr = (NPatchInfo*)pointer;
	free(nPatchInfoPtr);
}

BRIDGE_EXPORT void FreeFont(void* pointer) {
	if (pointer == NULL) return;

	Font* fontPtr = (Font*)pointer;

	Font font = *fontPtr;
	UnloadFont(font);
	free(fontPtr);
}

BRIDGE_EXPORT void FreeCamera(void* pointer) {
	if (pointer == NULL) return;

	Camera3D* cameraPtr = (Camera3D*)pointer;
	free(cameraPtr);
}

BRIDGE_EXPORT void FreeCamera2D(void* pointer) {
	if (pointer == NULL) return;

	Camera2D* camera2DPtr = (Camera2D*)pointer;
	free(camera2DPtr);
}

BRIDGE_EXPORT void FreeMesh(void* pointer) {
	if (pointer == NULL) return;

	Mesh* meshPtr = (Mesh*)pointer;

	Mesh mesh = *meshPtr;
	UnloadMesh(mesh);
	free(meshPtr);
}

BRIDGE_EXPORT void FreeShader(void* pointer) {
	if (pointer == NULL) return;

	Shader* shaderPtr = (Shader*)pointer;

	Shader shader = *shaderPtr;
	UnloadShader(shader);
	free(shaderPtr);
}

BRIDGE_EXPORT void FreeMaterialMap(void* pointer) {
	if (pointer == NULL) return;

	MaterialMap* materialMapPtr = (MaterialMap*)pointer;
	free(materialMapPtr);
}

BRIDGE_EXPORT void FreeMaterial(void* pointer) {
	if (pointer == NULL) return;

	Material* materialPtr = (Material*)pointer;

	Material material = *materialPtr;
	UnloadMaterial(material);
	free(materialPtr);
}

BRIDGE_EXPORT void FreeTransform(void* pointer) {
	if (pointer == NULL) return;

	Transform* transformPtr = (Transform*)pointer;
	free(transformPtr);
}

BRIDGE_EXPORT void FreeBoneInfo(void* pointer) {
	if (pointer == NULL) return;

	BoneInfo* boneInfoPtr = (BoneInfo*)pointer;
	free(boneInfoPtr);
}

BRIDGE_EXPORT void FreeModel(void* pointer) {
	if (pointer == NULL) return;

	Model* modelPtr = (Model*)pointer;

	Model model = *modelPtr;
	UnloadModel(model);
	free(modelPtr);
}

BRIDGE_EXPORT void FreeRay(void* pointer) {
	if (pointer == NULL) return;

	Ray* rayPtr = (Ray*)pointer;
	free(rayPtr);
}

BRIDGE_EXPORT void FreeRayCollision(void* pointer) {
	if (pointer == NULL) return;

	RayCollision* rayCollisionPtr = (RayCollision*)pointer;
	free(rayCollisionPtr);
}

BRIDGE_EXPORT void FreeBoundingBox(void* pointer) {
	if (pointer == NULL) return;

	BoundingBox* boundingBoxPtr = (BoundingBox*)pointer;
	free(boundingBoxPtr);
}

int main(int arc, char* argv) {
	return 0;
}