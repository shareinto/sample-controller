package main

import informers "github.com/shareinto/sample-controller/pkg/generated/informers/externalversions"

func main() {
	informers.NewSharedInformerFactory(nil, 1)
}
