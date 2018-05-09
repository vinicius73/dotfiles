set -gx PATH ~/.npm-global/bin ~/.config/yarn/global/node_modules/.bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/projects/go/bin $PATH

set -gx GOPATH ~/projects/go

set -gx ANDROID_HOME /opt/android-sdk/
set -gx JAVA_HOME /usr/lib/jvm/java-8-openjdk

if test -d /opt/android-sdk
  set -gx PATH /opt/android-sdk/build-tools/27.0.3/ $PATH
  set -gx PATH /opt/android-sdk/platform-tools /opt/android-sdk/build-tools/27.0.3/ /opt/android-sdk/tools $PATH
end
