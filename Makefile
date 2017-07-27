# vim:set noet:
.PHONY : vim tmux iterm2 zsh git conky  z

LNSOPT=-s

ifdef force
	ifeq ($(force),1)
		LNSOPT=-fs
	endif
endif

submodule:
	git submodule update --init

vim: submodule
	cd vim/Vundle.vim ; git checkout master ; git pull;
	mkdir -p ~/.vim/bundle/
	ln $(LNSOPT) $(CURDIR)/vim/vimrc ~/.vimrc
	ln $(LNSOPT) $(CURDIR)/vim/Vundle.vim ~/.vim/bundle/Vundle.vim
	vim -c "PluginInstall"
	cd ~/.vim/bundle/YouCompleteMe;git checkout 998303e2; git submodule update --init --recursive; ./install.sh --clang-completer
	brew install clang-format

tmux:
	ln $(LNSOPT) $(CURDIR)/tmux/tmux.conf ~/.tmux.conf

iterm2:
	ln $(LNSOPT) $(CURDIR)/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

zsh: submodule
	ln $(LNSOPT) $(CURDIR)/zsh/zshrc ~/.zshrc
	ln $(LNSOPT) $(CURDIR)/zsh/oh-my-zsh ~/.oh-my-zsh
	ln $(LNSOPT) $(CURDIR)/zsh/hit9.zsh-theme ~/.oh-my-zsh/themes/hit9.zsh-theme

git:
	ln $(LNSOPT) $(CURDIR)/git/gitconfig ~/.gitconfig

z:
	ln $(LNSOPT) $(CURDIR)/z/z.sh ~/.z.sh
