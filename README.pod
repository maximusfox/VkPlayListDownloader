VkPlayListDownloader
====================

Perl script for downloading user playlist to hard disk

Install dependence
	cpanm  --installdeps .

Edit config
	{
		"user": {
			"login": "YouLogin",
			"password": "You Password"
		},
		"path": {
			"saveTo": "./saved" // save mp3 to dir
		}
	}

Download music
	./bot --user patr14ek
