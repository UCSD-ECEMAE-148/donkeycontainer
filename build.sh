docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:jetpack  --file Dockerfile.jetpack --platform linux/arm64/v8 .
docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:cv2 --file Dockerfile.cv2 --progress plain --platform linux/arm64/v8 .
docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:utils --file Dockerfile.utils --platform linux/arm64/v8 .
docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:ros --file Dockerfile.ros --platform linux/arm64/v8 .
docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:devel --file Dockerfile --platform linux/arm64/v8 .
