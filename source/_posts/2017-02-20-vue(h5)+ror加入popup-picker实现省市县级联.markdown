---
layout: post
title:  "[vue] vue(h5)+ror加入popup-picker实现省市县级联"
date:   2017-02-20 09:14:49 +0800
category: vue
---


项目中导入:

    import Picker from '../picker'

    import Cell from '../cell'

    import Popup from '../popup'

    import InlineDesc from '../inline-desc'

    import { Flexbox, FlexboxItem } from '../flexbox'

    import array2string from '../../filters/array2String'

    import value2name from '../../filters/value2name'

    import uuidMixin from '../../libs/mixin_uuid

每个都需要导入，不能缺少。


ror部分: 

    def get_data
        @data = []
		    Province.includes(:cities).each do |province|
		        @data.push({
		                   name: province.name,
		                   value: province.name,
		                   parent: 0
		        })
						province.cities.includes(:towns).each do |city|
						    @data.push({
						                 name: city.name,
						                 value: city.name,
						                 parent: province.name
						    })
						    city.towns.each do |town|
						        @data.push({
						                   name: town.name,
						                   value: town.name,
						                   parent: city.name
						        })
						    end
					  end
				end
		  	@data
    end

vue(h5)部分：

    <group>
       <popup-picker :title="title" :data="data" :columns="3" v-model="address_array" ref="picker3" stlye="font-size: 20px;"></popup-picker>
    </group>

这里的data即为get_data的结果。address_array是当前所选中的省市县(如: ['陕西', '西安'， '新城区'])





