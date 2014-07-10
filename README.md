[![Build Status](https://travis-ci.org/UncleBill/f5.png?branch=master)](https://travis-ci.org/UncleBill/f5)

![f5 logo](http://pic.yupoo.com/island205/CuRETY9c/small.jpg)

 light static sever which will reload page when there are changes in server side!

icons belong to @teambox [Free-file-icons](https://github.com/teambox/Free-file-icons)

There is an [extra tool](https://github.com/UncleBill/crx4f5) works on chrome

#install
    $ (sudo) npm install -g f5

or if you want to test other fork

    $ (sudo) npm install -g https://github.com/<user>/f5/tarball/master
#how to use ?
- in the path which you want to be serve:


        #run command
        $ f5
        #or assign port
        $ f5 8080

- open your browser(any browser),and check out `http://localhost:${port you use,3000 default}`(for instance:http://localhost:3000),launch your html page, `f5` will reload it every time you modify it

- if modified file isn't html, `f5` won't reload the whole page but "reload" the attribute from all tags which attach the file


#force of `f5` ( working via LAN! ):
There is a short story:
**Luke** are coding html on his Laptop,and **Master Yoda**,via **LAN**, can watch the page auto reloading with **any** browser on **any** OS when **Luke** modify the file.That's the force of `f5`.

recommend shell script function:

```sh
function f55() { # run f5 background
    nohup f5 $1 > /dev/null 2>&1 &
    clear
    echo f5 is runing
}
```

Add this function to your SHELLRC file,restart the terminal(or source the SHELLRC file) and run `f55`(or `f55 <port>`)
( And executing `fg`,will call `f5` back in frontground. )

#Contributors

- [UncleBill](https://github.com/UncleBill)
- [node-migrator-bot](https://github.com/node-migrator-bot)

#TODO

[issue](https://github.com/island205/f5/issues?milestone=1&state=open)
