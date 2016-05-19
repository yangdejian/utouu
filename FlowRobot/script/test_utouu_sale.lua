
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

    print('ֱ�������¼�ӿ�')
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

    print('��һ������ȡ�µ�Login JessionID��ServerID')
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

    print('�ڶ�������ȡ��ȨCODE')
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
		print('HTML����ʧ��!')
		return
	end

	local ret = html:getFormInputs('/html/body/div/form')
	print('ret:'..xtable.tojson(ret))
	if(xtable.empty(ret) or xobject.empty(ret,'values')) then
		print('û���ҵ���¼��!')
		return
	end

    print('�������������¼�ӿ�')
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


	print("���Ĳ�����֤�Ƿ��ѵ�¼�ɹ�")



	print("���岽������cookie�����µ�¼״̬")



end



--- ��ȡ�˻��б�
--- ͬ���ģ�����html����ʾû�е�¼
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

--- sale������
--- ����HTML��ʾû�е�¼
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




-------------------------------------------- ��ʱ���� ------------------------------------------

function testLoadHTML()

	local html_str = [[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta name="renderer" content="webkit" />
<meta name="keywords" content="���ǿ�" />
<meta name="description" content="���ǿ�" />
<title>���ǿ�</title>
<meta property="wb:webmaster" content="44fdaeee953c4d86" />






<script>

	window['G_USER'] = {};
	G_USER['userName'] ='������ǰ��';G_USER['photo'] ='http://cdn1.utouu.com/picture/userphoto/243/49/1419639672846_B.jpg';
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
            <a href="/app" class="top_bg_1"> <img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_1.png" /> �ֻ��ͻ���</a>
            <div class="top_drop">
                <img src="http://cdn.utcard.cn/ui/pc/skin/images/qr_utcard.png" width="120" height="120" />
            </div>
            
        </div>
         <div class="fr clearbox">
            <div class="top_bg_3">��վ���� <img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_7.png" />
             <div class="top_a_box">
                    <ul>
                        <li><a  target="_blank" href="http://www.utouu.com">���ǹ���</a></li>
                        <li><a target="_blank" href="http://bbs.utouu.com">������̳</a></li>
                        <li><a target="_blank" href="http://www.bestkeep.cn">BESTKEEP</a></li>
                    </ul>
                </div> 
                </div>
            
            <span class="top_bg_2"> <img src="http://cdn1.utouu.com/picture/userphoto/243/49/1419639672846_B.jpg" /> <a href="/account">������ǰ��</a> <a href="/logout">�˳�</a> </span>
            
             
        </div>
    </div></div>
    <div class="head_menu clearbox"><div class="warp_box">
        <a href="/" class="head_menu_img fl"><img src="http://cdn.utcard.cn/ui/pc/skin/images/logo.png" width="169" height="80" /></a>
        <div class="head_menu_list fl">
            <ul class="clearbox">
                <li  class="head_avtive"><a href="/">��ҳ</a></li>
                <li  ><a href="/trade-center" >��������</a></li>
                <li  ><a href="/guide" class="head_a_bg">����ָ��<img src="http://cdn.utcard.cn/ui/pc/skin/images/icon_3.png" /></a></li>
 				<li  ><a  href="/account"  id="end" class="check_login" >��������</a><div id="msg"></div></li>
 				<li  ><a href="/app" >APP</a></li>
            </ul>
        </div>
         <div class="head_search">
            <input type="text" placeholder="�ǿ����������" id="head_u_search">
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
	    				$.alert("�����쳣�����Ժ����ԣ�","error");
	    			}else{
	    				$.alert('ϵͳ�쳣,',"error");
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
		el.href = '/utcard/'+datum["code"]; //url����
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
	    				$.alert("�����쳣�����Ժ����ԣ�","error");
	    			}else{
	    				$.alert('ϵͳ�쳣,',"error");
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
				<h2>���ǿ����°�</h2>
				<div class="rank_box">
					<div class="bd">
						

							<div class="rank_one clearbox">
								<div class="fl">
									<img src="http://cdn.utcard.cn/ui/pc/skin/images/trade_price_max.png" />
								</div>
								<div class="rank_fr">
									<h2><a href="/utcard/134551" target="_blank">FU302071���ǿ����룺134551��</a>
									</h2>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>65.22%</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;�֣�</span><em>65.22%</em>
										</p>
										<p>
											<span>�¾����棺</span><em>0.000/��</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ߣ�</span><em>25.00</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ͣ�</span><em>24.00</em>
										</p>
										<p>
											<span>�ɽ�����</span><em>6522</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>20.00</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�գ�</span><em>-- </em>
										</p>
										<p>
											<span>�ɽ��</span><em>41.13</em>
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
									<h2><a href="/utcard/134551" target="_blank">FU302071���ǿ����룺134551��</a>
									</h2>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>65.22%</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;�֣�</span><em>65.22%</em>
										</p>
										<p>
											<span>�¾����棺</span><em>0.000/��</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ߣ�</span><em>25.00</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ͣ�</span><em>24.00</em>
										</p>
										<p>
											<span>�ɽ�����</span><em>6522</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>20.00</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�գ�</span><em>-- </em>
										</p>
										<p>
											<span>�ɽ��</span><em>41.13</em>
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
									<h2><a href="/utcard/134248" target="_blank">FU301768���ǿ����룺134248��</a>
									</h2>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>2.54%</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;�֣�</span><em>2.54%</em>
										</p>
										<p>
											<span>�¾����棺</span><em>0.126/��</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ߣ�</span><em>99.99</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ͣ�</span><em>24.24</em>
										</p>
										<p>
											<span>�ɽ�����</span><em>254</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>24.24</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�գ�</span><em> 
													24.39
												</em>
										</p>
										<p>
											<span>�ɽ��</span><em>41.13</em>
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
									<h2><a href="/utcard/134551" target="_blank">FU302071���ǿ����룺134551��</a>
									</h2>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>65.22%</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;�֣�</span><em>65.22%</em>
										</p>
										<p>
											<span>�¾����棺</span><em>0.000/��</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ߣ�</span><em>25.00</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�ͣ�</span><em>24.00</em>
										</p>
										<p>
											<span>�ɽ�����</span><em>6522</em>
										</p>
									</div>
									<div class="rfr_line"></div>
									<div class="fr">
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;����</span><em>20.00</em>
										</p>
										<p>
											<span>��&nbsp;&nbsp;&nbsp;&nbsp;�գ�</span><em>-- </em>
										</p>
										<p>
											<span>�ɽ��</span><em>41.13</em>
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
							ʲô�ǰٷ򳤣�<br /> 1���ٷ���֪����ְҵ�����ˣ�Э��֪�������ڼ����������񣨲�����Ƹ����ͣ���ѵ�ȣ���<br /> 2��ÿλ�ٷ򳤸�����������100�ˣ����Լ�������Ա��ϵͳ���ݸ����˿�ƽ�����䣻<br /> 3���ֽ׶�ÿλ�ٷ���Ǯׯ����ÿ�»���ٺ»800Ԫ��<br /> 4���ٷ����滹����ÿ�³ֿ����ǡ���Ͻ���µ��Ǹ������Լ����̷ֺ졣<br /> 5��
							ÿ�������5���ٷ򳤡�<br /> <br /> ��γ�Ϊ�ٷ򳤣�<br /> 1���˲��г�����ְҵ����<br /> 2��֪��ͬ������ſ�����ԤԼ���Ի�ȡ�ٷ��ʸ�֤��<br /> 3���ֿ����ڱ������ǿ�������ǰ�壬�ҳֿ���һֱ���õ���501��
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
            <h2><span>�ǿ����¼����� </span> <a href="/r-new" target="_blank" class="more">����&gt;</a></h2>
           	<div id="tk_new_selected"></div>
        </div>
        <div class="fr rank_tab">
            <h2><span>�ǿ��Ƿ�����</span> <a href="/r-gain" target="_blank" class="more">����&gt;</a></h2>
           <div id="tk_gain_selected"></div>
        </div>
        <div class="clearfix"></div>
        <div class="fl rank_tab">
            <h2><span>�ǿ��ɽ�������</span> <a href="/r-amount"  target="_blank" class="more">����&gt;</a></h2>
           <div id="tk_amount_selected"></div>
        </div>
        <div class="fr rank_tab">
            <h2><span>�ǿ��ɽ�������</span><a href="/r-price"  target="_blank" class="more">����&gt;</a></h2>
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
    	 <p><a target="_blank" href="http://www.utouu.com//about#content">��������</a> | <a target="_blank" href="http://www.utouu.com//about#recent-work">�칫����</a> | <a target="_blank" href="http://www.utouu.com//about#contact_m">��ϵ����</a> | <a target="_blank" href="http://www.utouu.com//about#services">��ƸӢ��</a> | <a target="_blank" href="http://www.utouu.com//about#fr_showcase">��ر���</a> </p>
<p>���ߵ绰��400-720-9815    ��ַ���Ϻ����ֶ���������·181�ţ�����԰¬ɭ���ݣ�&nbsp;&nbsp;<a href="http://www.jinmaopartners.com/" target="_blank">�Ϻ���ï������ʦ�������ṩ����֧��</a></p>
<p>Copyright ? 2014-2016 www.utcard.cn, All rights reserved.UTOUU.  ��ICP��14043004��-1 &nbsp;&nbsp;�Ϻ���������Ƽ����޹�˾ ��Ȩ����</p>
<p>
<a href="https://search.szfw.org/cert/l/CX20141225006151006258" target="_blank"><i class="icon1"></i></a>
<a href="https://www.sgs.gov.cn/lz/licenseLink.do?method=licenceView&entyId=dov73ne26zbqq0il7cc2pu4w5t4td2np5d" target="_blank"><i class="icon3"> </i></a></p>
    </div>
     <div class="b_r">
        <img src="http://cdn.utcard.cn/ui/pc/skin/images/qr_utcard.png" width="120" height="120"  />
        <p>���ǿ��ֻ��ͻ���</p>
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
		print('HTML����ʧ��!')
		return
	end

	local nodes = html:getElements('/html/head/script')
	--G_USER['userName'] ='������ǰ��'
	print(nodes:GetLength())
	local script_str = nodes:Get(1):GetAttribute('innerText')
	script_str = string.gsub(script_str,"%s*","")
	print(script_str)
	local a,b = string.find(script_str,"G_USER%['userName']=")
	print(tostring(a))
	print(tostring(b))
	if(a == nil) then
		print("��¼ʧ��!")
		return
	end
	local nick_name = string.sub(script_str,b,b+20)
	print("��¼�ɹ���"..tostring(nick_name))
	--print(#nodes)
	--[[
	if(not nodes:IsValid()) then
		print("�Ҳ���ָ���ı�ǩ:script")
		return
	end

	print(nodes:GetAttribute('innerText'))]]
	--if(xtable.empty(nodes)) then

	--end 

end
