---
layout: post
title:  "[Ubuntu] 支付宝支付使用openssl生成key"
date:   2017-04-10 09:14:49 +0800
category: Ubuntu
---


		支付宝支付使用openssl生成公钥，私钥，pkcs8格式密钥


		#打开openssl
		openssl

		#生成私钥
		genrsa -out rsa_private_key.pem 2048

		#转换私钥格式为pkcs8格式
		pkcs8 -topk8 -inform PEM -in rsa_private_key.pem -outform PEM -nocrypt -out rsa_private_key_pkcs8.pem

		#生成公钥
		rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem

		生成的3个.pem文件会在当前文件夹下,使用cat命令打开。公钥填写到支付宝开放平台，私钥填写在接口处，供app调用。



