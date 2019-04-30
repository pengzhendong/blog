---
title: Laravel OAuth2 (二) ---配置与数据库设计
date: 2015-09-30 13:30:41
updated: 2015-09-30 13:59:22
tags: Laravel
---

## 前言

使用 OAuth2 进行第三方登陆分为好几种情况，例如完全第三方登陆，不保存任何用户信息，或者第三方登陆后保存用户信息关联本站账号。个人觉得保存一下用户信息比较妥当(虽然这样注册的时候让用户觉得很不方便，但是第二次使用就不会这么麻烦了)，如果数据库中不存在该用户则重定向到注册页面，否则查找关联的本站账号，登陆。

<!-- more -->

## 修改回调的URL

因为要绑定本站账号，所以回调的 URL 应该是注册页面。在注册页面判断是否该用户已存在，是则直接登陆，否则填写注册信息。对应的 **.env** 文件也要修改：**GITHUB_REDIRECT_URI=http:http://suip.app/auth/register**

## 数据库迁移文件

``` php
class CreateSocialUsersTable extends Migration
{
    public function up()
    {
        Schema::create('social_users', function (Blueprint $table) {
            $table->increments('id');
            $table->string('type');
            $table->integer('social_user_id')->unsigned();
            $table->integer('user_id')->unsigned();
            $table->string('nickname')->nullable();
            $table->string('name')->nullable();
            $table->string('email')->nullable();
            $table->string('avatar')->nullable();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->timestamps();
        });
    }
    
    public function down()
    {
        Schema::drop('social_users');
    }
}
```

这里的 **user_id** 就是本站账号的 id ，注册成功自然会将第三方的信息与本站账号关联。

### 第三方用户模型

``` php
class SocialUser extends Model
{
    protected $table = 'social_users';
    protected $fillable = [
    	'type',
    	'user_id',
    	'nickname',
    	'name',
    	'email',
    	'avatar'
    	];
    public function user()
    {
        return $this->belongsTo('App\User');
    }
}
```

实现第三方登陆绑定本站账号的配置就完成了。