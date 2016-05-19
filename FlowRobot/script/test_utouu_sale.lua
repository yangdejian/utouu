
require 'sys'
require 'custom.common.wclient'
require 'custom.common.xhtml'



function main()
	testLoadHTML()
	--login()
end

function login2()
	local domain = 'https://api.open.utouu.com'
	local http = wclient()
	local html = xhtml()
	http:enable_pop(true)
	http:enable_redirect(true)
	
	
	clear_cookies(http,domain)
	local cookies = [[SERVERID=2c0446bb7b703bc6726eac084973f3d5|1463629291|1463629291;JSESSIONID=8F7DA2DE3C7D3E4D4381EF158CB39C0B]]
	set_cookies(http,cookies,domain)
	http:set_cookie(domain,'pgv_pvi=9271464960;path=/')
	--local cookies = [[SERVERID=050e5dff1b4769d22f1a5ca241569aab|1463622632|1463622631;JSESSIONID=4D070B2A5BDA3680585689C3E3CFFB23]]
	--http:set_cookie(domain,'SERVERID=050e5dff1b4769d22f1a5ca241569aab|1463622632|1463622631;path=/')
	--http:set_httponly_cookie(domain,'JSESSIONID=4D070B2A5BDA3680585689C3E3CFFB23;path=/')


	local ret_str = [[{"values":{"authCode":["100011","10002","10003"],"password":"","username":"","oauth20_state":"acf682e7-9473-46b1-91d1-80d27ac55627"},"keys":["username","password","oauth20_state","authCode"]}]]
   	local ret = xtable.parse(ret_str)

    print('直接请求登录接口')
    local ret_vals = ret.values
	local user_name = '13051df880135'
	local pwd = '19868111'
	local post_data = string.format('username=%s&password=%s&oauth20_state=%s&authCode=%s&authCode=%s&authCode=%s',
		user_name,pwd,ret_vals["oauth20_state"],ret_vals["authCode"][1],ret_vals["authCode"][2],ret_vals["authCode"][3])
	print('post_data:'..tostring(post_data))
	
	local request_input = {
		method = "post",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = post_data,
		url = 'https://api.open.utouu.com/oauth/grant',
		header = [[Host: api.open.utouu.com
Connection: keep-alive
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: https://api.open.utouu.com
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Content-Type: application/x-www-form-urlencoded
Referer: https://api.open.utouu.com/oauth/authorize?response_type=code&client_id=0ysY8xuFSE-kk_0uELFEFA&redirect_uri=http%253A%252F%252Fwww.utcard.cn%252Fget-token&state=utcard&display=pc
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.8]]
	}
	local content = http:query(request_input, {}, 300)
	print('content:'..tostring(content))
	local cookies = http:get_all_cookie(domain)
	print('cookies:'..tostring(cookies))

end

function login()
	local domain = 'http://www.utcard.cn'
	local http = wclient()
	local html = xhtml()
	http:enable_pop(true)
	http:enable_redirect(true)

    print('第一步：获取新的Login JessionID和ServerID')
	local trade_input = {
		method = "get",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = '',
		url = 'http://www.utcard.cn/trade-center',
		header = [[Host: www.utcard.cn
Connection: keep-alive
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Accept-Encoding: gzip, deflate, sdch
Accept-Language: zh-CN,zh;q=0.8]]
	}

	clear_cookies(http)
	local content = http:query(trade_input, {}, 300)
	print('content:'..tostring(content))
	local login_cookies = http:get_all_cookie(domain)
	print('login_cookies:'..tostring(login_cookies))

    print('第二步：获取授权CODE')
	local request_input = {
		method = "get",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = '',
		url = 'http://www.utcard.cn/authorize',
		header = [[Upgrade-Insecure-Requests: 1
Host: www.utcard.cn
Connection: keep-alive
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Referer: http://www.utcard.cn/guide
Accept-Encoding: gzip, deflate, sdch
Accept-Language: zh-CN,zh;q=0.8
Cache-Control: no-cache]]
	}

	--Cookie: Hm_lvt_d1465a68d33395555c8f3729ee367842=1462327916; td_cookie=3527515483; JSESSIONID=F3847B61DD00BF0A21F7D193BE1B07E8; bidding_ipo_time_sort=-1; SERVERID=a6cd409da1955d3d65c4e8a36419da60|1462853518|1462853515; CNZZDATA1257117916=1794138884-1452589768-http%253A%252F%252Fstock.utouu.com%252F%7C1462851228
	local content = http:query(request_input, {}, 3000)
	print('content:'..tostring(content))
	local rep_sta = http:get_response_status()
	print('rep_sta:'..tostring(rep_sta))

	local load_ret = html:load(content)
	print('load_ret:'..tostring(load_ret))
	if(not load_ret) then
		print('HTML加载失败!')
		return
	end

	local ret = html:getFormInputs('/html/body/div/form')
	print('ret:'..xtable.tojson(ret))
	if(xtable.empty(ret) or xobject.empty(ret,'values')) then
		print('没有找到登录表单!')
		return
	end

    print('第三步：请求登录接口')
	local http = wclient()
	set_cookies(http,cookies,ndomain)
	http:set_cookie(ndomain,'pgv_pvi=9271464960;path=/')

    local ret_vals = ret.values
	local user_name = '13051880135'
	local pwd = '198681'
	local post_data = string.format('username=%s&password=%s&oauth20_state=%s&authCode=%s&authCode=%s&authCode=%s',
		user_name,pwd,ret_vals["oauth20_state"],ret_vals["authCode"][1],ret_vals["authCode"][2],ret_vals["authCode"][3])
	print('post_data:'..tostring(post_data))
	
	local request_input = {
		method = "post",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = post_data,
		url = 'https://api.open.utouu.com//oauth/grant',
		header = [[Host: api.open.utouu.com
Connection: keep-alive
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: https://api.open.utouu.com
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Content-Type: application/x-www-form-urlencoded
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.8]]
	}
	local content = http:query(request_input, {}, 300)
	print('content:'..tostring(content))


	print("第四步：验证是否已登录成功")



	print("第五步：保存cookie并更新登录状态")



end



--- 获取账户列表
--- 同样的，返回html，表示没有登录
function query_account_info()
	local http = wclient()
	local request_input = {
		method = "post",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = '',
		url = 'http://www.utcard.cn/account/info',
		header = [[Host: www.utcard.cn
Connection: keep-alive
Accept: application/json, text/javascript, */*; q=0.01
Origin: http://www.utcard.cn
X-Requested-With: XMLHttpRequest
User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Referer: http://www.utcard.cn/account
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.8]]
	}

	clear_cookies(http,domain)

	local cookies = [[td_cookie=3523176925;JSESSIONID=F2A5E799C9A6CE422E0EE10E0549CF54;bidding_ipo_time_sort=-1;CNZZDATA1257117916=1794138884-1452589768-http%253A%252F%252Fstock.utouu.com%252F%7C1462845828;SERVERID=41dd1778c35414ce2f056f26d214729b|1462850145|1462848886]]
	local domain = 'http://www.utcard.cn'
	--http:set_cookie(domain, 'td_cookie=ydj_test; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	--http:set_cookie(domain, 'bidding_ipo_time_sort=ydj_test; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	--http:set_httponly_cookie(domain, 'JSESSIONID=000000; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	--http:set_cookie(domain,'td_cookie=3523176925;path=/')
	--http:set_cookie(domain,'bidding_ipo_time_sort=-1;path=/')
	http:set_cookie(domain,'SERVERID=a6cd409da1955d3d65c4e8a36419da60|1462859209|1462859187;path=/')
	http:set_httponly_cookie(domain,'JSESSIONID=EAF2AA9E9DD1FED9E601045DCE4C25A5;path=/')

	local content = http:query(request_input, {}, 300)
	print('content:'..tostring(content))
end

--- sale：卖出
--- 返回HTML表示没有登录
function sale()
	local http = wclient()
	local post_data = 'unitCode=133369&unitId=942&salePrice=25&saleAmount=1'
	local request_input = {
		method = "post",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = post_data,
		url = 'http://www.utcard.cn/trade/sale',
		header = [[Host: www.utcard.cn
Connection: keep-alive
Accept: application/json, text/javascript, */*; q=0.01
Origin: http://www.utcard.cn
X-Requested-With: XMLHttpRequest
User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
Referer: http://www.utcard.cn/utcard/133369
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.8]]
	}

	local cookies = [[td_cookie=3523176925;JSESSIONID=F2A5E799C9A6CE422E0EE10E0549CF54;bidding_ipo_time_sort=-1;CNZZDATA1257117916=1794138884-1452589768-http%253A%252F%252Fstock.utouu.com%252F%7C1462845828;SERVERID=41dd1778c35414ce2f056f26d214729b|1462850145|1462848886]]
	local domain = 'http://www.utcard.cn'

	http:set_cookie(domain, 'td_cookie=ydj_test; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	http:set_cookie(domain, 'bidding_ipo_time_sort=ydj_test; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	http:set_httponly_cookie(domain, 'JSESSIONID=000000; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	--http:set_cookie(domain,'td_cookie=3523176925;path=/')
	--http:set_cookie(domain,'bidding_ipo_time_sort=-1;path=/')
	http:set_cookie(domain,'SERVERID=41dd1778c35414ce2f056f26d214729b|1462850145|1462848886;path=/')
	--http:set_httponly_cookie(domain,'JSESSIONID=F2A5E799C9A6CE422E0EE10E0549CF54;path=/')

	local content = http:query(request_input, {}, 300)
	print('content:'..tostring(content))
end

function clear_cookies(http,domain)

	local domain = domain or 'http://www.utcard.cn'

	http:set_cookie(domain,'pgv_pvi=0; Expires=Tue, 15-Mar-2011 08:53:21 GMT; path=/')
	http:set_cookie(domain,'SERVERID=000; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')
	http:set_httponly_cookie(domain, 'JSESSIONID=000; Expires=Tue, 15-Mar-2011 08:53:21 GMT; Path=/')

end

function set_cookies(http,cookies,domain)

	local domain = domain or 'http://www.utcard.cn'
	print('domain:'..domain)
	local arr = xstring.split(cookies,';')
	for i,v in pairs(arr) do
		local cookie = xstring.trim(v)
		print('domain:'..tostring(domain))
		print('set-cookie:'..tostring(cookie))
		if(xstring.start_with(cookie,'SERVERID')) then
			http:set_cookie(domain,string.format("%s;Path=/", cookie))
		end
		if(xstring.start_with(cookie,'JSESSIONID')) then
			http:set_httponly_cookie(domain, string.format("%s;Path=/", cookie))
		end
	end

end




-------------------------------------------- 暂时不用 ------------------------------------------

function testLoadHTML()

	local html_str = [[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta name="renderer" content="webkit" />
<meta name="keywords" content="有糖卡" />
<meta name="description" content="有糖卡" />
<title>有糖卡</title>
<meta property="wb:webmaster" content="44fdaeee953c4d86" />






<script>

	window['G_USER'] = {};
	G_USER['userName'] ='摸索着前行';G_USER['photo'] ='http://cdn1.utouu.com/picture/userphoto/243/49/1419639672846_B.jpg';
</script>

<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/jquery-1.10.2.min.js"></script>
<link rel="icon" href="http://cdn.utcard.cn/ui/pc/skin/static/favicon.ico" type="image/x-icon" />
<link type="image/x-icon" href="http://cdn.utcard.cn/icon/favicon.ico" rel="shortcut icon" />
<style type="text/css">
	
	.red{
		color: red;
	}
	.green{
		color: green;
	}
	.error .help-inline{
		color: red;
	}
	.page_main{
		min-height: 800px;
	}
	
</style>
<link href="http://cdn.utcard.cn/ui/pc/skin/css/utouu.jquery.extends.pagenationstable.css" rel="stylesheet" type="text/css" />
<link href="http://cdn.utcard.cn/ui/pc/skin/css/ui-dialog.css" rel="stylesheet" type="text/css" />
<link href="http://cdn.utcard.cn/ui/pc/skin/css/style.css" rel="stylesheet" type="text/css" />
<style type="text/css">
.userdefined-153704 .j-module {
	zoom: 1;
	overflow: hidden;
}

.snow-container {
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	pointer-events: none;
	z-index: 100001;
}
</style>
</head>
<body>

	<!--head-->
	



<div class="head">
    <div class="top clearbox"><div class="warp_box">
        <div class="fl top_drop_a">
            <a href="/app" class="top_bg_1"> <img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_1.png" /> 手机客户端</a>
            <div class="top_drop">
                <img src="http://cdn.utcard.cn/ui/pc/skin/images/qr_utcard.png" width="120" height="120" />
            </div>
            
        </div>
         <div class="fr clearbox">
            <div class="top_bg_3">网站导航 <img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_7.png" />
             <div class="top_a_box">
                    <ul>
                        <li><a  target="_blank" href="http://www.utouu.com">有糖官网</a></li>
                        <li><a target="_blank" href="http://bbs.utouu.com">有糖论坛</a></li>
                        <li><a target="_blank" href="http://www.bestkeep.cn">BESTKEEP</a></li>
                    </ul>
                </div> 
                </div>
            
            <span class="top_bg_2"> <img src="http://cdn1.utouu.com/picture/userphoto/243/49/1419639672846_B.jpg" /> <a href="/account">摸索着前行</a> <a href="/logout">退出</a> </span>
            
             
        </div>
    </div></div>
    <div class="head_menu clearbox"><div class="warp_box">
        <a href="/" class="head_menu_img fl"><img src="http://cdn.utcard.cn/ui/pc/skin/images/logo.png" width="169" height="80" /></a>
        <div class="head_menu_list fl">
            <ul class="clearbox">
                <li  class="head_avtive"><a href="/">首页</a></li>
                <li  ><a href="/trade-center" >交易中心</a></li>
                <li  ><a href="/guide" class="head_a_bg">新手指南<img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_3.png" /></a></li>
 				<li  ><a  href="/account"  id="end" class="check_login" >个人中心</a><div id="msg"></div></li>
 				<li  ><a href="/app" >APP</a></li>
            </ul>
        </div>
         <div class="head_search">
            <input type="text" placeholder="糖卡代码或名称" id="head_u_search">
            <a id="head_u_search_button"></a>
        </div>
    </div></div>
</div>
<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/autocomplete/jquery.autocomplete.js"></script>
<link href="http://cdn.utcard.cn/ui/pc/skin/js/autocomplete/jquery.autocomplete.css" rel="stylesheet" type="text/css" />
<script type="text/javascript">

$('#head_u_search').autocomplete({
	 dropdownWidth:'auto',
	 appendMethod:'replace',
	 autoselect:'true' ,
	 valid: function () {
	  return true;
	 },
	 source:[
	  function (q, add){
		  var stockcodeValue = $("#head_u_search").val();
			var stockcodeLen = stockcodeValue.length;
			if (stockcodeLen <3) {
				return false;
			}
		   $.ajax({
	    		url:'/utcard/get-autocomplete-list',
	    		type: 'post',
	    		dataType: 'json',
	    		data:{'prefix':$("#head_u_search").val(),type:'all'},
	    		success: function(ret){
	    			if(ret.success){
	    				var suggestions = [];
					    if (ret.data) {
					     $.each(ret.data, function(i, val){  
					      suggestions.push(val);  
					     });
					     add(suggestions);
					    }
	    			}
	    		},
	    		error:function(ret){
	    			$("#head_u_search").val("");
	    			if('timeout'==statusText){
	    				$.alert("请求异常，请稍后再试！","error");
	    			}else{
	    				$.alert('系统异常,',"error");
	    			}
	    		}    
		   });
	  },
	 ],
	 getTitle:function(item){
		  return item["code"]+"-"+item["name"];
		 },
		 getValue:function(item){
			 return item["code"];
		 }
	}).on('selected.xdsoft',function(e,datum){
		if(!datum || !datum["code"]){
			return false;
		}
		var el = document.createElement("a");
		document.body.appendChild(el);
		el.href = '/utcard/'+datum["code"]; //url连接
		el.target = '_blank'; //
		el.click();
		document.body.removeChild(el);
	});
	
	$("#head_u_search_button").mouseover(function(){
		
		$("#head_u_search_button").attr("href",'');
		
		 $.ajax({
	    		url:'/utcard/get-code',
	    		type: 'post',
	    		dataType: 'json',
	    		data:{'stock':$("#head_u_search").val()},
	    		success: function(ret){
	    			if(ret.success){
	    				$("#head_u_search_button").attr("href",'/utcard/'+ret.data).attr("target","_blank");
	    				$("#head_u_search_button").click();
	    			}
	    		},
	    		error:function(ret){
	    			if('timeout'==statusText){
	    				$.alert("请求异常，请稍后再试！","error");
	    			}else{
	    				$.alert('系统异常,',"error");
	    			}
	    		}    
		   });
	});
	
</script>

	<!-- head_end -->
	<div class="banner">
		<div class="bd">
			<div class="warp_banner">
				<div class="warp_box clearbox">
					<img class="banner_logo" src="http://cdn.utcard.cn/ui/pc/skin/images/logo_b.png" />
				</div>
			</div>
			<div class="warp_banner2">
				<div class="warp_box clearbox">
					
				</div>
			</div>
			
		</div>
		<div class=' snow3d-163771' instanceId='6059610' style="margin-bottom: 10px;" module-name="effects">
						<div class="mc" style="min-height: 0px;">
							<div class="snow-container"></div>
						</div>
					</div>
		<div class="hd">
			<ul>
				<li class="on">1</li>
				<li>2</li>
				<!-- <li>3</li> -->
			</ul>
		</div>
		
	</div>
	<!-- banner_end -->

	<!--content-->
	<div class="warp_content">
		<div class="warp_box">

			<div class="rank">
				<h2>有糖卡最新榜单</h2>
				<div class="rank_box">
					<div class="bd">
						

							<div class="rank_one clearbox">
								<div class="fl">
									<img src="http://cdn.utcard.cn/ui/pc/skin/images/trade_price_max.png" />
								</div>
								<div class="rank_fr">
									<h2><a href="/utcard/134551" target="_blank">FU302071（糖卡代码：134551）</a>
									</h2>
									<div class="fr">
										<p>
											<span>振&nbsp;&nbsp;&nbsp;&nbsp;幅：</span><em>65.22%</em>
										</p>
										<p>
											<span>换&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;手：</span><em>65.22%</em>
										</p>
										<p>
											<span>月均收益：</span><em>0.000/张</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;高：</span><em>25.00</em>
										</p>
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;低：</span><em>24.00</em>
										</p>
										<p>
											<span>成交量：</span><em>6522</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>今&nbsp;&nbsp;&nbsp;&nbsp;开：</span><em>20.00</em>
										</p>
										<p>
											<span>昨&nbsp;&nbsp;&nbsp;&nbsp;收：</span><em>-- </em>
										</p>
										<p>
											<span>成交额：</span><em>41.13</em>
										</p>
									</div>
									<div class="rank_top_box">
										<p>
											<span class='fcolor_red'>25.00</span> +5.00(+25.00%)
										</p>
										<img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_up.png" id="change_arrow" />
									</div>
								</div>
							</div>
						

							<div class="rank_one clearbox">
								<div class="fl">
									<img src="http://cdn.utcard.cn/ui/pc/skin/images/trade_amount_max.png" />
								</div>
								<div class="rank_fr">
									<h2><a href="/utcard/134551" target="_blank">FU302071（糖卡代码：134551）</a>
									</h2>
									<div class="fr">
										<p>
											<span>振&nbsp;&nbsp;&nbsp;&nbsp;幅：</span><em>65.22%</em>
										</p>
										<p>
											<span>换&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;手：</span><em>65.22%</em>
										</p>
										<p>
											<span>月均收益：</span><em>0.000/张</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;高：</span><em>25.00</em>
										</p>
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;低：</span><em>24.00</em>
										</p>
										<p>
											<span>成交量：</span><em>6522</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>今&nbsp;&nbsp;&nbsp;&nbsp;开：</span><em>20.00</em>
										</p>
										<p>
											<span>昨&nbsp;&nbsp;&nbsp;&nbsp;收：</span><em>-- </em>
										</p>
										<p>
											<span>成交额：</span><em>41.13</em>
										</p>
									</div>
									<div class="rank_top_box">
										<p>
											<span class='fcolor_red'>25.00</span> +5.00(+25.00%)
										</p>
										<img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_up.png" id="change_arrow" />
									</div>
								</div>
							</div>
						

							<div class="rank_one clearbox">
								<div class="fl">
									<img src="http://cdn.utcard.cn/ui/pc/skin/images/trade_gain_max.png" />
								</div>
								<div class="rank_fr">
									<h2><a href="/utcard/134248" target="_blank">FU301768（糖卡代码：134248）</a>
									</h2>
									<div class="fr">
										<p>
											<span>振&nbsp;&nbsp;&nbsp;&nbsp;幅：</span><em>2.54%</em>
										</p>
										<p>
											<span>换&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;手：</span><em>2.54%</em>
										</p>
										<p>
											<span>月均收益：</span><em>0.126/张</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;高：</span><em>99.99</em>
										</p>
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;低：</span><em>24.24</em>
										</p>
										<p>
											<span>成交量：</span><em>254</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>今&nbsp;&nbsp;&nbsp;&nbsp;开：</span><em>24.24</em>
										</p>
										<p>
											<span>昨&nbsp;&nbsp;&nbsp;&nbsp;收：</span><em> 
													24.39
												</em>
										</p>
										<p>
											<span>成交额：</span><em>41.13</em>
										</p>
									</div>
									<div class="rank_top_box">
										<p>
											<span class='fcolor_red'>99.99</span> +75.75(+312.50%)
										</p>
										<img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_up.png" id="change_arrow" />
									</div>
								</div>
							</div>
						

							<div class="rank_one clearbox">
								<div class="fl">
									<img src="http://cdn.utcard.cn/ui/pc/skin/images/trade_pop_max.png" />
								</div>
								<div class="rank_fr">
									<h2><a href="/utcard/134551" target="_blank">FU302071（糖卡代码：134551）</a>
									</h2>
									<div class="fr">
										<p>
											<span>振&nbsp;&nbsp;&nbsp;&nbsp;幅：</span><em>65.22%</em>
										</p>
										<p>
											<span>换&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;手：</span><em>65.22%</em>
										</p>
										<p>
											<span>月均收益：</span><em>0.000/张</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;高：</span><em>25.00</em>
										</p>
										<p>
											<span>最&nbsp;&nbsp;&nbsp;&nbsp;低：</span><em>24.00</em>
										</p>
										<p>
											<span>成交量：</span><em>6522</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>今&nbsp;&nbsp;&nbsp;&nbsp;开：</span><em>20.00</em>
										</p>
										<p>
											<span>昨&nbsp;&nbsp;&nbsp;&nbsp;收：</span><em>-- </em>
										</p>
										<p>
											<span>成交额：</span><em>41.13</em>
										</p>
									</div>
									<div class="rank_top_box">
										<p>
											<span class='fcolor_red'>25.00</span> +5.00(+25.00%)
										</p>
										<img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_up.png" id="change_arrow" />
									</div>
								</div>
							</div>
						
					</div>
					<div class="tips">
						<div class="tips_con">
							什么是百夫长？<br /> 1：百夫长是知府的职业经理人，协助知府打理府内几乎所有事务（布衣招聘，解雇，培训等）；<br /> 2：每位百夫长负责管理府内最多100人（含自己），人员由系统依据府内人口平均分配；<br /> 3：现阶段每位百夫长由钱庄代发每月基本俸禄800元；<br /> 4：百夫长收益还包括每月持卡分糖、所辖布衣的糖赋收益以及电商分红。<br /> 5：
							每个府最多5名百夫长。<br /> <br /> 如何成为百夫长？<br /> 1：人才市场设置职业意向；<br /> 2：知府同意后在门客中心预约面试获取百夫长资格证；<br /> 3：持卡量在本府大糖块中排名前五，且持卡数一直不得低于501。
						</div>
					</div>
					<div class="hd">
						<ul>
							
								<li>0</li>
							
								<li>1</li>
							
								<li>2</li>
							
								<li>3</li>
							
						</ul>
					</div>

				</div>
			</div>
			  <div class="tk_selected">
        <div class="fl rank_tab">
            <h2><span>糖卡最新价排行 </span> <a href="/r-new" target="_blank" class="more">更多&gt;</a></h2>
           	<div id="tk_new_selected"></div>
        </div>
        <div class="fr rank_tab">
            <h2><span>糖卡涨幅排行</span> <a href="/r-gain" target="_blank" class="more">更多&gt;</a></h2>
           <div id="tk_gain_selected"></div>
        </div>
        <div class="clearfix"></div>
        <div class="fl rank_tab">
            <h2><span>糖卡成交量排行</span> <a href="/r-amount"  target="_blank" class="more">更多&gt;</a></h2>
           <div id="tk_amount_selected"></div>
        </div>
        <div class="fr rank_tab">
            <h2><span>糖卡成交额排行</span><a href="/r-price"  target="_blank" class="more">更多&gt;</a></h2>
           <div id="tk_price_selected"></div>
        </div>
        <div class="clearfix"></div>

    </div>

		</div>
	</div>
	<!-- content_end -->


	<!-- bottom_menu -->
	


<!-- bottom_menu -->
<div class="bottom_menu"><div class="bottom_menu_box">
    <div class="b_l">
    	 <p><a target="_blank" href="http://www.utouu.com//about#content">关于我们</a> | <a target="_blank" href="http://www.utouu.com//about#recent-work">办公环境</a> | <a target="_blank" href="http://www.utouu.com//about#contact_m">联系我们</a> | <a target="_blank" href="http://www.utouu.com//about#services">诚聘英才</a> | <a target="_blank" href="http://www.utouu.com//about#fr_showcase">相关报道</a> </p>
<p>热线电话：400-720-9815    地址：上海市浦东新区博成路181号（世博园卢森堡馆）&nbsp;&nbsp;<a href="http://www.jinmaopartners.com/" target="_blank">上海金茂凯德律师事务所提供法务支持</a></p>
<p>Copyright ? 2014-2016 www.utcard.cn, All rights reserved.UTOUU.  沪ICP备14043004号-1 &nbsp;&nbsp;上海悠唐网络科技有限公司 版权所有</p>
<p>
<a href="https://search.szfw.org/cert/l/CX20141225006151006258" target="_blank"><i class="icon1"></i></a>
<a href="https://www.sgs.gov.cn/lz/licenseLink.do?method=licenceView&entyId=dov73ne26zbqq0il7cc2pu4w5t4td2np5d" target="_blank"><i class="icon3"> </i></a></p>
    </div>
     <div class="b_r">
        <img src="http://cdn.utcard.cn/ui/pc/skin/images/qr_utcard.png" width="120" height="120"  />
        <p>有糖卡手机客户端</p>
    </div> 
    <div class="clearfix"></div>
</div></div>
<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/utcard/common.js"></script>
<script type="text/javascript">var cnzz_protocol = (("https:" == document.location.protocol) ? " https://" : " http://");document.write(unescape("%3Cspan id='cnzz_stat_icon_1257117916'%3E%3C/span%3E%3Cscript src='" + cnzz_protocol + "w.cnzz.com/q_stat.php%3Fid%3D1257117916' type='text/javascript'%3E%3C/script%3E"));</script>
<!-- bottom_menu_end -->




	<!-- bottom_menu_end -->
</body>

<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/lib.js"></script>
<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/utouu.jquery.extends.pagenationstable.js"></script>
<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/jquery.SuperSlide.2.1.1.js"></script>
<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/utcard.js"></script>
<script type="text/javascript" src="http://cdn.utcard.cn/ui/pc/skin/js/utcard/index.js"></script>
<script>
	 var isLogin="true";
	$(".banner").slide({
		mainCell : ".bd",
		effect : "fold",
		autoPlay : true
	});
	$(".rank_box").slide({
		mainCell : ".bd",
		effect : "leftLoop",
		autoPlay : true
	});
	var window = window;
	if (window.opener && !window.opener.closed && isLogin) {
		window.opener.location.href = window.opener.location.href;
		window.close();
	}
</script>
</html>]]

	local html = xhtml()
	local load_ret = html:load(html_str)
	print('load_ret:'..tostring(load_ret))
	if(not load_ret) then
		print('HTML加载失败!')
		return
	end

	local nodes = html:getElements('/html/head/script')
	--G_USER['userName'] ='摸索着前行'
	print(nodes:GetLength())
	local script_str = nodes:Get(1):GetAttribute('innerText')
	script_str = string.gsub(script_str,"%s*","")
	print(script_str)
	local a,b = string.find(script_str,"G_USER%['userName']=")
	print(tostring(a))
	print(tostring(b))
	if(a == nil) then
		print("登录失败!")
		return
	end
	local nick_name = string.sub(script_str,b,b+20)
	print("登录成功："..tostring(nick_name))
	--print(#nodes)
	--[[
	if(not nodes:IsValid()) then
		print("找不到指定的标签:script")
		return
	end

	print(nodes:GetAttribute('innerText'))]]
	--if(xtable.empty(nodes)) then

	--end 

end
