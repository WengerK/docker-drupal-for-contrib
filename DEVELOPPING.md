# Developing on Docker Drupal for Contrib

* Issues should be filed at
https://github.com/wengerk/docker-drupal-for-contrib/issues
* Pull requests can be made against
https://github.com/wengerk/docker-drupal-for-contrib/pulls

## 📦 Repositories

Github repo

  ```bash
  git@github.com:wengerk/docker-drupal-for-contrib.git
  ```

## 🔧 Prerequisites

First of all, you need to have the following tools installed globally
on your environment:

  * docker
  * docker-compose
  * make

## 🐞 Build or Debug a single image

Each version-directory is composed of a specific `Makefile` when the whole pull/push/build/tests process belongs.

Therefore, you can use those `Makefile` files to:

* `build`: Build the image;
* `build-nc`: Build the image without caches and pull the base image from remote;
* `test`: Test the image;
* `push`: Push the image on Docker hub;
* `shell`: Run a shell inside the image for debugging;
* `run`: Run the image - will be destroyed once the command finished);
* `start`: Start the container;
* `stop`: Stop the container;
* `logs`: Read the logs;
* `clean`: Remove the image from local image distribution system;
* `release`: Create a new release for this image.

## 🏗 Builds all image variants

After updating any image, don't forget to update all the images variants by running the following command:

    ./update.sh

You can also locally build all images or a specific one:

    ./update.sh --build=<8.8|9.0|all|latest>
    
And if you have the credentials (run docker login), you can manually publish an image:

    ./update.sh --publish=<8|all|latest>
    
Otherwise, Travis take care of releasing new tags on the default branch.

## 🏆 Tests

Travis take care of running tests against defined tags on every push.

You can run the tests by yourself executing the `Makefile` on each version-directory.

Example to run the Drupal 9.0 tests-suits:

```shell
cd ./9/9.0 && make build && make test
```

You can also use the root `./update.sh [-t|--test=]` command to run the tests (useful for bulk tests):

    ./update.sh --test=<8.8|9.0|all|latest>
    ./update.sh -t
