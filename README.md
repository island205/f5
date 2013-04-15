[![Build Status](https://travis-ci.org/UncleBill/f5.png?branch=master)](https://travis-ci.org/UncleBill/f5)

![f5 logo](http://pic.yupoo.com/island205/CuRETY9c/small.jpg)

 light static sever which will reload page when there are changes in server side!

icons belong to @teambox [Free-file-icons](https://github.com/teambox/Free-file-icons)

There is an [extra tool](https://github.com/UncleBill/crx4f5) works on chrome

#install
    $ (sudo) npm install -g f5

or if you want to test other fork

    $ git clone <git-respo-url>
    $ cd <git-clone-dir>
    $ (sudo) npm install -g

#how to use ?
- in the path which you want to be serve:


        #run command
        $ f6
        #or assign port
        $ f5 8080

- open your browser(any browser),and check out `http://localhost:${port you use,3000 default}`,launch your html page, `f5` will reload it every time you modify it

- if modified file isn't html, `f5` won't reload the whole page but "reload" the attribute from all tags which attach the file

- `f5` can works via **LAN** too!

#Contributors

- [UncleBill](https://github.com/UncleBill)
- [node-migrator-bot](https://github.com/node-migrator-bot)

#TODO

[issue](https://github.com/island205/f5/issues?milestone=1&state=open)
