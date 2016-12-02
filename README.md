logmon
======
"logmon" is a simple log monitoring tool written in Perl. It was originally made for IBM Systems Director to watch Linux log files, but is used other various systems because of high maintainability and versatility for written in 120 or less lines.

The original download page (http://www-06.ibm.com/jp/domino01/mkt/cnpages7.nsf/page/default-00057580) had already gone. We could just look [document(PDF)](https://www-06.ibm.com/jp/domino04/pc/support/Sylphd08.nsf/1e97b730bd4fa8f249256a840020d047/cdbc8a525d5ebfa849257b2c00088545/$FILE/ATTU1G46.pdf/Linux%20%E3%83%AD%E3%82%B0%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E7%9B%A3%E8%A6%96%E3%82%AC%E3%82%A4%E3%83%89_v1.2.pdf).

Original script has some issues, but thankfully some people has already revised them.

* ref: https://github.com/moomindani/logmon/commit/69cc44509a19f4c746d253d525a74634ad700c54
* ref: https://github.com/moomindani/logmon/commit/058c58f1fecc6b0ac827aad47fe7bd2dac710528


## 1. How to install

### 1.1. Legacy system: System V init(CentOS 6.x or older)
```sh
$ git clone https://github.com/kacchan822/logmon.git
$ cd logmon
$ sudo ./setup.sh
```
`setup.sh` copy logmon dir's files to `/etc/logmon` and `/etc/init.d`, and set `chkconfig` to start  "logmon" on boot.


## 2. How to Operate

### 2.1. Legacy system: System V init(CentOS 6.x or older)
Starting "logmon"
```sh
$ /etc/init.d/logmon start
```
Stopping "logmon"
```sh
$ sudo /etc/init.d/logmon stop
```
Restart "logmon"
```sh
$ sudo /etc/init.d/logmon restart
```
Check configuration "logmon"
```sh
$ sudo /etc/init.d/logmon check
```


## 3. How to configure
Configuration file is `/etc/logmon/logmon.conf`.

### 3.1. Basic Configuration file format
```
:Target Log File
(Keywords)
Actions
```
In configuration file,
* Blank line and line starts with __#__ is ignored.
* Line starts with __:__ is path to monitoring log file.
* Line other than above is execute commands.
In Actions(execute commands line), __<%%%%>__ is replaced with the line matched.

### 3.2. Examples
```
# Monitoring messages log
:/var/log/messages
(Error|ERROR|error)
echo -e "Error cached in messages.\n<%%%%>\n" | mail -s "[CAUTION] Some error occurred!" root@example.com

# Monitoring secure log
:/var/log/secure
(authentication failure)
echo -e "Secure Information \n<%%%%>\n" | mail -s "[CAUTION] Authentication failure!" root@example.com
```

After editing configuration file, you should run `/etc/init.d/logmon check` to check configuration file format.
If configuration file is correct, you can see messages like below.
```
Config file: logmon.conf

Logfile: /var/log/messages
  Message: (Error|ERROR|error)
    Action: echo -e "Error cached in messages.\n<%%%%>\n" | mail -s "[CAUTION] Some error occurred!" root@example.com

Logfile: /var/log/secure
  Message: (authentication failure)
    Action: echo -e "Secure Information \n<%%%%>\n" | mail -s "[CAUTION] Authentication failure!" root@example.com\
```

## X. Appendix
There is a some reference web pages.
* [一文字パッチでlogmonをログローテートに対応させる - $web->{note};](http://n8.hatenablog.com/entry/20111210/p2)
* [ログ監視ツール logmon （修正パッチつき） パソコン鳥のブログ/ウェブリブログ](http://vogel.at.webry.info/201402/article_2.html)
* [つれづれ: ログ自動監視ツールSwatchとlogmonのエスケープ処理 ](http://antas.jp/blog/ina/archives/2011/07/swatch_logmon_escape.html)
* [logmonは気を付けて使わないとOSコマンドインジェクションの脆弱性を生むことが | OpenMemo](http://labo.samuraistyle.org/blog/archives/531)
