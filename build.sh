# docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:jetpack512  --file Dockerfile.jetpack --platform linux/arm64/v8 .
# docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:cv2-490jp5 --file Dockerfile.cv2 --platform linux/arm64/v8 .
# docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:utils --file Dockerfile.utils --platform linux/arm64/v8 .
docker build --tag ghcr.io/ucsd-ecemae-148/donkeycontainer:devel --file Dockerfile --platform linux/arm64/v8 .