# XFCE on CentOS Stream, with noVNC

```
docker pull cubio/centos-vnc-xfce:latest
docker run -d --shm-size=256m -p 5901:5901 -p 6905:6901 -e VNC_PW=aVeryGoodPassword cubio/centos-vnc-xfce:latest
```

Point your VNC client to ```localhost:5901```, or your browser to ```localhost:6901```.

Default password is ```novncpassword```, or define one with the ```VNC_PW``` environment variable.

A simple pod/svc k8s manifest could be..

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: centos-vnc-xfce
  name: centos-vnc-xfce
spec:
  securityContext:
    runAsUser: 12345
    runAsGroup: 12345
  containers:
  - image: cubio/centos-vnc-xfce:latest # better to target a unique tag here
    imagePullPolicy: Always
    name: centos-vnc-xfce
    ports:
    - containerPort: 6901
      protocol: TCP
    volumeMounts:
    - mountPath: /dev/shm
      name: shm
    env:
    - name: VNC_PW
      value: aGoodPassword
    - name: VNC_COL_DEPTH
      value: "24"
    - name: VNC_RESOLUTION
      value: "1696x954"
  restartPolicy: Never
  volumes:
  - name: shm
    emptyDir:
      sizeLimit: 256Mi
      medium: Memory
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: centos-vnc-xfce
  name: centos-vnc-xfce
spec:
  ports:
  - name: port6901
    port: 6901
  selector:
    app: centos-vnc-xfce
  type: NodePort

```

Last edited by JBW on 09/05/2021