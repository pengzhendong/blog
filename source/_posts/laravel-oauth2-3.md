---
title: Laravel OAuth2 (三) ---使用 services 和 facades
date: 2015-09-30 16:30:51
updated: 2015-09-30 17:12:32
tags: Laravel
---

## 前言

既然要判断用户是否存在，然后创建用户，那么就要实现几个功能函数。为了方便调用，于是我尝试着写了第一个service 和 facade 。

<!-- more -->

## 创建 Facade

``` php
class Social extends Facade
{
    protected static function getFacadeAccessor()
    {
        return 'social';
    }
}
```

## 创建 Service

``` php
use Laravel\Socialite\Facades\Socialite;
use App\SocialUser;
use App\User;

class SocialService
{
    public function whetherRegistered()
    {
        $user = Socialite::driver('github')->user();

        $newUser = array();
        $newUser['id'] = $user->getId();
        $newUser['nickname'] = $user->getNickname();
        $newUser['name'] = $user->getName();
        $newUser['email'] = $user->getEmail();
        $newUser['avatar'] = $user->getAvatar();

        $socialUser = SocialUser::where('type', 'github')->where('social_user_id', $newUser['id'])->first();
        if ($socialUser) {
            return $socialUser;
        }
        return $newUser;
    }

    public function createSocialUser(User $user, $newUser)
    {
        $socialUser = new SocialUser();

        $socialUser->type = 'github';
        $socialUser->social_user_id = $newUser['id'];
        $socialUser->user_id = $user->id;;
        $socialUser->nickname = $newUser['nickname'];
        $socialUser->name = $newUser['name'];
        $socialUser->email = $newUser['email'];
        $socialUser->avatar = $newUser['avatar'];
        $socialUser->save();
        return $socialUser;
    }

    public function searchUser(SocialUser $socialUser)
    {
        $user = User::where('id', $socialUser->user_id)->first();
        return $user;
    }

    public function handle()
    {
        $newUser = $this->whetherRegistered();
        if (is_a($newUser, 'App\SocialUser')) {
            $user = $this->searchUser($newUser);
            return $user;
        }
        return $newUser;
    }
}
```
    
在 Service 里面实现了判断用户是否存在，创建用户，查找本站用户，放回用户信息三个函数。

## 创建 Service Provider

``` php
use App\Services\SocialService\SocialService;

public function register()
{
    $this->app->singleton('social', function()  //这里的'social'就是上面创建的 facade 的返回值
    {
        return new SocialService;  //这里的 SocialService 就是刚刚创建的 Service
    });
}
```

关于服务容器的具体使用：[官方文档](http://laravel-china.org/docs/5.0/container)

## 注册 ServiceProvider 和 Facade

在 **config/app.php** 文件中注册：

``` php
'providers' => [   //只有注册了的服务才能用
    // Other service providers...

    App\Providers\SocialServiceProvider::class,
],

'aliases' => [   //个人理解Facade就是将一些类的很长的路径用一个单词表示
    // Other facades...
    'Social'    => App\Services\Facades\Social::class,
],
```
    
最后一步，安装插件：

``` bash
$ composer install
```
    
现在就能使用服务了。

## 修改注册页面

``` php
use App\Services\SocialService;
use App\Services\Facades\Social;

trait RegistersUsers
{
    use RedirectsUsers;
    
    public function getRegister()
    {
        if (Input::has('code')) {
            $user = Social::handle();
            if (is_a($user, 'App\User')) {
                Auth::login($user);
                return redirect($this->redirectPath());
            }
            Session::put('newUser', $user);
            return view('auth.register')->with('newUser', $user);
        }
        return view('auth.register');
    }
    
    public function postRegister(Request $request)
    {
        $user = $this->create($request->all());
        if (Session::get('newUser')) {
            Social::createSocialUser($user, Session::get('newUser'));
        }
        Auth::login($user);

        return redirect($this->redirectPath());
    }
}
``` 

未注册的话则会跳转到注册页面，注册账号后退出登陆，然后重新访问 **http://suip.app/login/github** 就会直接进入首页啦~