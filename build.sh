docker build --tag jetpack  --file Dockerfile.jetpack --platform linux/arm64/v8 .
docker build --tag buildcv2 --file Dockerfile.cv2 --progress plain --platform linux/arm64/v8 .
docker build --tag final --file Dockerfile --platfork linux/arm64/v8 .