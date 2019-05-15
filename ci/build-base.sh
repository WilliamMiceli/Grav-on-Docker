docker build --pull --build-arg "GRAV_VERSION=$GRAV_VERSION" -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" -t "$CI_REGISTRY_IMAGE:$GRAV_VERSION" .
docker push "$CI_REGISTRY_IMAGE:$GRAV_VERSION"
docker save --output "./images/$CI_COMMIT_SHORT_SHA.tar" "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"