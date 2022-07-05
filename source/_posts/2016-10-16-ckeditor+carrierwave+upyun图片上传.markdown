---
layout: post
title:  "[RubyOnRails]ckeditor+carrierwave+upyun图片上传"
date:   2016-10-19 09:14:49 +0800
category: RubyOnRails
---

ckeditor+carrierwave+upyun图片上传

1. 添加gem

    gem 'ckeditor'

参照地址:

    https://github.com/galetahub/ckeditor



    gem 'upyun'

    gem 'carrierwave'

    gem 'mini_magick'



gem "carrierwave-upyun"(NOTE: 此 Gem 是一个 CarrierWave 的组件，你需要配合 CarrierWave 一起使用。

) , 参照地址:

    https://github.com/nowa/carrierwave-upyun

1.新建一个 initializer

    config/initializers/carrierwave.rb



    # -*- encoding : utf-8 -*-

    CarrierWave.configure do |config|

      config.storage = :upyun

      config.upyun_username = Settings.operator

      config.upyun_password = Settings.password

      config.upyun_bucket = Settings.bucket

      config.upyun_bucket_host = "http://images.touring.com.cn"

    end




2. 生成uploader

    rails generate uploader ckeditor_picture

    # -*- encoding : utf-8 -*-
    class CkeditorPictureUploader < CarrierWave::Uploader::Base

        include Ckeditor::Backend::CarrierWave

        # Include RMagick or ImageScience support:

        # include CarrierWave::RMagick

        include CarrierWave::MiniMagick

        # include CarrierWave::ImageScience

        CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

        # Choose what kind of storage to use for this uploader:

        storage :file

        # Override the directory where uploaded files will be stored.

        # This is a sensible default for uploaders that are meant to be mounted:

        def store_dir

        "uploads/ckeditor/pictures/#{model.id}"

        # "#{model.class.to_s.underscore}/#{mounted_as}"

        end

        # Provide a default URL as a default if there hasn't been a file uploaded:

        # def default_url

        #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')

        # end



        # Process files as they are uploaded:

        # process :scale => [200, 300]

        #

        # def scale(width, height)

        #   # do something

        # end



        process :read_dimensions



        # Create different versions of your uploaded files:

        # TODO 是不是这里引起的? -- 大师

        version :thumb do

        process :resize_to_fill => [118, 100]

        end



        version :content do

        process :resize_to_limit => [800, 800]

        end



        # Add a white list of extensions which are allowed to be uploaded.

        # For images you might use something like this:

        def extension_white_list

        Ckeditor.image_file_types

        end

        def original_filename

        @original_filename

        end

        def filename

        if super.present?

          original = "途铃图片"

          if original_filename.split('.').present?

            original = original_filename.split('.').first

          end

          Rails.logger.info "== model: #{model.inspect}"

          model.uploader_secure_token ||= SecureRandom.uuid.gsub("-","")

          Rails.logger.debug("(BaseUploader.filename) #{model.uploader_secure_token}")

          "#{original}__#{model.uploader_secure_token}.#{file.extension.downcase}"

        end

        end

    end

3. 修改uploader(这一步很关键)

    storage :file 修改为 storage :upyun



4. 生成相应的ActiveRecord

    rails generate ckeditor:install --orm=active_record --backend=carrierwave



5. Load generated models(加载相应生成的model)

    config.autoload_paths += %w(#{config.root}/app/models/ckeditor)



6. Mount the Ckeditor::Engine in your routes (config/routes.rb):(修改route.rb, 路由文件)

    mount Ckeditor::Engine => '/ckeditor'



7. 在application.js 中引用


    //= require ckeditor/init


8. 修改 config/initializers/assets.rb


    Rails.application.config.assets.precompile += %w(ckeditor/config.js)



9. 在simple_form中的调用

    <%= f.cktext_area :details %>



10 . Controller 中的写法

    bucket = Settings.bucket

    operator = Settings.operator

    password = Settings.password

    air_port_params = params[:air_port]

    if air_port_params.present? and air_port_params[:logo].present?

      upload_file = air_port_params[:logo]

      upyun = Upyun::Rest.new(bucket, operator, password)

      new_file_name = Time.now.to_i

      remote_file = "/image/air_port_logo/#{new_file_name}"

      response = upyun.put remote_file, upload_file.read

    End



