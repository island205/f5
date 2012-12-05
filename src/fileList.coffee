subdirs = document.getElementsByClassName 'subdir'

for subdir in subdirs
	subdir.addEventListener 'click',()->
		this.getElementsByTagName('ul')[0].style.display = 'block'

