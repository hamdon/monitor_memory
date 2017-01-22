#!/usr/bin/env python
# -*- coding: utf-8 -*-
import urllib2
import simplejson as json
import sys
import os
import ConfigParser
reload(sys)
sys.setdefaultencoding("utf-8")

class weChat:
    def __init__(self,url,Corpid,Secret):
        url = '%s/cgi-bin/gettoken?corpid=%s&corpsecret=%s' % (url,Corpid,Secret)
        res = self.url_req(url)
        self.token = res['access_token']

    def url_req(self,url,method='get',data={}):
        if method == 'get':
            req = urllib2.Request(url)
            res = json.loads(urllib2.urlopen(req).read())
        elif method == 'post':
                        req = urllib2.Request(url,data)
                        res = json.loads(urllib2.urlopen(req).read())
        else:
            print 'error request method...exit'
            sys.exit()
        return res
    def send_message(self,userlist,content,agentid=0):
        self.userlist = userlist
        self.content = content.decode('utf-8')
        url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s' % self.token
        data = {
                      "touser": "",
                      "toparty": "",
                      "totag": "",
                      "msgtype": "text",
                      "agentid": "2",
                      "text": {
                          "content": ""
                      },
                      "safe":"0"
                   }
        data['touser'] = userlist
        data['agentid'] = agentid
        data['text']['content'] = content
        data = json.dumps(data,encoding='utf-8',ensure_ascii=False)
#        print data
        res = self.url_req(url,method='post',data=data)
        if res['errmsg'] == 'ok':
            print 'send sucessed!!!'
        else:
            print 'send failed!!'
            print res




if __name__ == '__main__':
      userlist = '@all'
      content = sys.argv[1:]
      content = '\n'.join(content)
      path=os.getcwd()
      cf = ConfigParser.ConfigParser()
      cf.read(path+"/wechat.conf")

      corpid=cf.get("wechat","corpid")
      secret=cf.get("wechat","secret")
      url=cf.get("wechat","url")

      wechat = weChat(url,corpid,secret)
      wechat.send_message(userlist,content,cf.get("wechat","agentid"))
