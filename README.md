Simple Diagnostics Container
--

If you are tired of `apk --update add curl` everytime


Tools installed
--
openssh
nmap
curl
tcpdump
git
kubectl
helm
vim


Running Instructions
--
`docker run -d -p 2200:22 faraazkhan/diagnostics`

`kubectl run -it diagnostics --image faraazkhan/diagnostics -- bash`
