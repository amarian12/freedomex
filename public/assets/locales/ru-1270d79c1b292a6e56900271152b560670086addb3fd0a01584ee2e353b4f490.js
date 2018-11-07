!function(I18n){"use strict";var slice=Array.prototype.slice,padding=function(number){return("0"+number.toString()).substr(-2)},DATE={day_names:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],abbr_day_names:["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],month_names:[null,"January","February","March","April","May","June","July","August","September","October","November","December"],abbr_month_names:[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],meridian:["AM","PM"]},NUMBER_FORMAT={precision:3,separator:".",delimiter:",",strip_insignificant_zeros:!1},CURRENCY_FORMAT={unit:"$",precision:2,format:"%u%n",delimiter:",",separator:"."},PERCENTAGE_FORMAT={precision:3,separator:".",delimiter:""},SIZE_UNITS=[null,"kb","mb","gb","tb"],DEFAULT_OPTIONS={defaultLocale:"en",locale:"en",defaultSeparator:".",placeholder:/(?:\{\{|%\{)(.*?)(?:\}\}?)/gm,fallbacks:!1,translations:{}};I18n.reset=function(){this.defaultLocale=DEFAULT_OPTIONS.defaultLocale,this.locale=DEFAULT_OPTIONS.locale,this.defaultSeparator=DEFAULT_OPTIONS.defaultSeparator,this.placeholder=DEFAULT_OPTIONS.placeholder,this.fallbacks=DEFAULT_OPTIONS.fallbacks,this.translations=DEFAULT_OPTIONS.translations},I18n.initializeOptions=function(){"undefined"==typeof this.defaultLocale&&null!==this.defaultLocale&&(this.defaultLocale=DEFAULT_OPTIONS.defaultLocale),"undefined"==typeof this.locale&&null!==this.locale&&(this.locale=DEFAULT_OPTIONS.locale),"undefined"==typeof this.defaultSeparator&&null!==this.defaultSeparator&&(this.defaultSeparator=DEFAULT_OPTIONS.defaultSeparator),"undefined"==typeof this.placeholder&&null!==this.placeholder&&(this.placeholder=DEFAULT_OPTIONS.placeholder),"undefined"==typeof this.fallbacks&&null!==this.fallbacks&&(this.fallbacks=DEFAULT_OPTIONS.fallbacks),"undefined"==typeof this.translations&&null!==this.translations&&(this.translations=DEFAULT_OPTIONS.translations)},I18n.initializeOptions(),I18n.locales={},I18n.locales.get=function(locale){var result=this[locale]||this[I18n.locale]||this["default"];return"function"==typeof result&&(result=result(locale)),result instanceof Array==!1&&(result=[result]),result},I18n.locales["default"]=function(locale){var countryCode,locales=[],list=[];return locale&&locales.push(locale),!locale&&I18n.locale&&locales.push(I18n.locale),I18n.fallbacks&&I18n.defaultLocale&&locales.push(I18n.defaultLocale),locales.forEach(function(locale){countryCode=locale.split("-")[0],~list.indexOf(locale)||list.push(locale),I18n.fallbacks&&countryCode&&countryCode!==locale&&!~list.indexOf(countryCode)&&list.push(countryCode)}),locales.length||locales.push("en"),list},I18n.pluralization={},I18n.pluralization.get=function(locale){return this[locale]||this[I18n.locale]||this["default"]},I18n.pluralization["default"]=function(count){switch(count){case 0:return["zero","other"];case 1:return["one"];default:return["other"]}},I18n.currentLocale=function(){return this.locale||this.defaultLocale},I18n.isSet=function(value){return value!==undefined&&null!==value},I18n.lookup=function(scope,options){options=this.prepareOptions(options);var locale,scopes,translations,locales=this.locales.get(options.locale).slice();locales[0];for(scope.constructor===Array&&(scope=scope.join(this.defaultSeparator)),options.scope&&(scope=[options.scope,scope].join(this.defaultSeparator));locales.length;)if(locale=locales.shift(),scopes=scope.split(this.defaultSeparator),translations=this.translations[locale]){for(;scopes.length&&(translations=translations[scopes.shift()])!==undefined&&null!==translations;);if(translations!==undefined&&null!==translations)return translations}if(this.isSet(options.defaultValue))return options.defaultValue},I18n.meridian=function(){var time=this.lookup("time"),date=this.lookup("date");return time&&time.am&&time.pm?[time.am,time.pm]:date&&date.meridian?date.meridian:DATE.meridian},I18n.prepareOptions=function(){for(var subject,args=slice.call(arguments),options={};args.length;)if("object"==typeof(subject=args.shift()))for(var attr in subject)subject.hasOwnProperty(attr)&&(this.isSet(options[attr])||(options[attr]=subject[attr]));return options},I18n.createTranslationOptions=function(scope,options){var translationOptions=[{scope:scope}];return this.isSet(options.defaults)&&(translationOptions=translationOptions.concat(options.defaults)),this.isSet(options.defaultValue)&&(translationOptions.push({message:options.defaultValue}),delete options.defaultValue),translationOptions},I18n.translate=function(scope,options){var translation;return options=this.prepareOptions(options),this.createTranslationOptions(scope,options).some(function(translationOption){if(this.isSet(translationOption.scope)?translation=this.lookup(translationOption.scope,options):this.isSet(translationOption.message)&&(translation=translationOption.message),translation!==undefined&&null!==translation)return!0},this)?("string"==typeof translation?translation=this.interpolate(translation,options):translation instanceof Object&&this.isSet(options.count)&&(translation=this.pluralize(options.count,translation,options)),translation):this.missingTranslation(scope)},I18n.interpolate=function(message,options){options=this.prepareOptions(options);var placeholder,name,regex,value,matches=message.match(this.placeholder);if(!matches)return message;for(;matches.length;)name=(placeholder=matches.shift()).replace(this.placeholder,"$1"),value=this.isSet(options[name])?options[name].toString().replace(/\$/gm,"_#$#_"):this.missingPlaceholder(placeholder,message),regex=new RegExp(placeholder.replace(/\{/gm,"\\{").replace(/\}/gm,"\\}")),message=message.replace(regex,value);return message.replace(/_#\$#_/g,"$")},I18n.pluralize=function(count,scope,options){var translations,keys,key,message;if(options=this.prepareOptions(options),!(translations=scope instanceof Object?scope:this.lookup(scope,options)))return this.missingTranslation(scope);for(keys=this.pluralization.get(options.locale)(Math.abs(count));keys.length;)if(key=keys.shift(),this.isSet(translations[key])){message=translations[key];break}return options.count=String(count),this.interpolate(message,options)},I18n.missingTranslation=function(){var message='[missing "';return message+=this.currentLocale()+".",message+=slice.call(arguments).join("."),message+='" translation]'},I18n.missingPlaceholder=function(placeholder){return"[missing "+placeholder+" value]"},I18n.toNumber=function(number,options){options=this.prepareOptions(options,this.lookup("number.format"),NUMBER_FORMAT);var precision,formattedNumber,negative=number<0,parts=Math.abs(number).toFixed(options.precision).toString().split("."),buffer=[];for(number=parts[0],precision=parts[1];0<number.length;)buffer.unshift(number.substr(Math.max(0,number.length-3),3)),number=number.substr(0,number.length-3);return formattedNumber=buffer.join(options.delimiter),options.strip_insignificant_zeros&&precision&&(precision=precision.replace(/0+$/,"")),0<options.precision&&precision&&(formattedNumber+=options.separator+precision),negative&&(formattedNumber="-"+formattedNumber),formattedNumber},I18n.toCurrency=function(number,options){return options=this.prepareOptions(options,this.lookup("number.currency.format"),this.lookup("number.format"),CURRENCY_FORMAT),number=this.toNumber(number,options),number=options.format.replace("%u",options.unit).replace("%n",number)},I18n.localize=function(scope,value){switch(scope){case"currency":return this.toCurrency(value);case"number":return scope=this.lookup("number.format"),this.toNumber(value,scope);case"percentage":return this.toPercentage(value);default:return scope.match(/^(date|time)/)?this.toTime(scope,value):value.toString()}},I18n.parseDate=function(date){var matches,convertedDate,fraction;if("object"==typeof date)return date;if(matches=date.toString().match(/(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2}):(\d{2})([\.,]\d{1,3})?)?(Z|\+00:?00)?/)){for(var i=1;i<=6;i++)matches[i]=parseInt(matches[i],10)||0;matches[2]-=1,fraction=matches[7]?1e3*("0"+matches[7]):null,convertedDate=matches[8]?new Date(Date.UTC(matches[1],matches[2],matches[3],matches[4],matches[5],matches[6],fraction)):new Date(matches[1],matches[2],matches[3],matches[4],matches[5],matches[6],fraction)}else"number"==typeof date?(convertedDate=new Date).setTime(date):date.match(/([A-Z][a-z]{2}) ([A-Z][a-z]{2}) (\d+) (\d+:\d+:\d+) ([+-]\d+) (\d+)/)?(convertedDate=new Date).setTime(Date.parse([RegExp.$1,RegExp.$2,RegExp.$3,RegExp.$6,RegExp.$4,RegExp.$5].join(" "))):(date.match(/\d+ \d+:\d+:\d+ [+-]\d+ \d+/),(convertedDate=new Date).setTime(Date.parse(date)));return convertedDate},I18n.strftime=function(date,format){var options=this.lookup("date"),meridianOptions=I18n.meridian();options||(options={}),options=this.prepareOptions(options,DATE);var weekDay=date.getDay(),day=date.getDate(),year=date.getFullYear(),month=date.getMonth()+1,hour=date.getHours(),hour12=hour,meridian=11<hour?1:0,secs=date.getSeconds(),mins=date.getMinutes(),offset=date.getTimezoneOffset(),absOffsetHours=Math.floor(Math.abs(offset/60)),absOffsetMinutes=Math.abs(offset)-60*absOffsetHours,timezoneoffset=(0<offset?"-":"+")+(absOffsetHours.toString().length<2?"0"+absOffsetHours:absOffsetHours)+(absOffsetMinutes.toString().length<2?"0"+absOffsetMinutes:absOffsetMinutes);return 12<hour12?hour12-=12:0===hour12&&(hour12=12),format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=(format=format.replace("%a",options.abbr_day_names[weekDay])).replace("%A",options.day_names[weekDay])).replace("%b",options.abbr_month_names[month])).replace("%B",options.month_names[month])).replace("%d",padding(day))).replace("%e",day)).replace("%-d",day)).replace("%H",padding(hour))).replace("%-H",hour)).replace("%I",padding(hour12))).replace("%-I",hour12)).replace("%m",padding(month))).replace("%-m",month)).replace("%M",padding(mins))).replace("%-M",mins)).replace("%p",meridianOptions[meridian])).replace("%S",padding(secs))).replace("%-S",secs)).replace("%w",weekDay)).replace("%y",padding(year))).replace("%-y",padding(year).replace(/^0+/,""))).replace("%Y",year)).replace("%z",timezoneoffset)},I18n.toTime=function(scope,dateString){var date=this.parseDate(dateString),format=this.lookup(scope);return date.toString().match(/invalid/i)?date.toString():format?this.strftime(date,format):date.toString()},I18n.toPercentage=function(number,options){return options=this.prepareOptions(options,this.lookup("number.percentage.format"),this.lookup("number.format"),PERCENTAGE_FORMAT),(number=this.toNumber(number,options))+"%"},I18n.toHumanSize=function(number,options){for(var unit,precision,kb=1024,size=number,iterations=0;kb<=size&&iterations<4;)size/=kb,iterations+=1;return 0===iterations?(unit=this.t("number.human.storage_units.units.byte",{count:size}),precision=0):(unit=this.t("number.human.storage_units.units."+SIZE_UNITS[iterations]),precision=size-Math.floor(size)==0?0:1),options=this.prepareOptions(options,{precision:precision,format:"%n%u",delimiter:""}),number=this.toNumber(size,options),number=options.format.replace("%u",unit).replace("%n",number)},I18n.t=I18n.translate,I18n.l=I18n.localize,I18n.p=I18n.pluralize}("undefined"==typeof exports?this.I18n||(this.I18n={}):exports),I18n.translations={ru:{brand:"Peatio",submit:"\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u044c",funds:{deposit:"\u041f\u043e\u043f\u043e\u043b\u043d\u0438\u0442\u044c",withdraw:"\u0412\u044b\u0432\u0435\u0441\u0442\u0438",deposit_fiat:{title:"\u041f\u043e\u043f\u043e\u043b\u043d\u0438\u0442\u044c \u0432 {{currency}}",description:"\u0421\u0432\u044f\u0436\u0438\u0442\u0435\u0441\u044c \u0441 \u043c\u0435\u043d\u0435\u0434\u0436\u0435\u0440\u043e\u043c \u0412\u0430\u0448\u0435\u0433\u043e \u0431\u0430\u043d\u043a\u0430 \u0434\u043b\u044f \u0438\u043d\u0441\u0442\u0440\u0443\u043a\u0446\u0438\u0439."},deposit_coin:{title:"\u041f\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u0435 \u0432 {{currency}}",address:"\u0410\u0434\u0440\u0435\u0441","open-wallet":"\u0418\u0441\u043f\u043e\u043b\u044c\u0437\u0443\u0439\u0442\u0435 \u0412\u0430\u0448 \u043b\u043e\u043a\u0430\u043b\u044c\u043d\u044b\u0439 \u043a\u043e\u0448\u0435\u043b\u0435\u043a, \u043c\u043e\u0431\u0438\u043b\u044c\u043d\u043e\u0435 \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u0435 \u0438\u043b\u0438 \u043e\u043d\u043b\u0430\u0439\u043d \u0441\u0435\u0440\u0432\u0438\u0441 \u0434\u043b\u044f \u043e\u043f\u043b\u0430\u0442\u044b.",detail:"\u041f\u043e\u0436\u0430\u043b\u0443\u0439\u0441\u0442\u0430 \u0441\u043a\u043e\u043f\u0438\u0440\u0443\u0439\u0442\u0435 \u0430\u0434\u0440\u0435\u0441 \u0432 \u0412\u0430\u0448 \u043a\u043e\u0448\u0435\u043b\u0435\u043a, \u0432\u0432\u0435\u0434\u0438\u0442\u0435 \u0441\u0443\u043c\u043c\u0443, \u043a\u043e\u0442\u043e\u0440\u0443\u044e \u0412\u044b \u0445\u043e\u0442\u0438\u0442\u0435 \u0437\u0430\u0447\u0438\u0441\u043b\u0438\u0442\u044c \u0438 \u043f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u0435 \u0437\u0430\u0447\u0438\u0441\u043b\u0435\u043d\u0438\u0435.","scan-qr":"\u041e\u0442\u0441\u043a\u0430\u043d\u0438\u0440\u0443\u0439\u0442\u0435 QR \u043a\u043e\u0434 \u0434\u043b\u044f \u043e\u043f\u043b\u0430\u0442\u044b \u0438\u0437 \u043c\u043e\u0431\u0438\u043b\u044c\u043d\u043e\u0433\u043e \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u044f.",after_deposit:"\u041a\u0430\u043a \u0442\u043e\u043b\u044c\u043a\u043e \u0412\u044b \u0437\u0430\u043a\u043e\u043d\u0447\u0438\u0442\u0435 \u043e\u0442\u043f\u0440\u0430\u0432\u043a\u0443, \u0412\u044b \u043c\u043e\u0436\u0435\u0442\u0435 \u043f\u0440\u043e\u0432\u0435\u0440\u0438\u0442\u044c \u0441\u0442\u0430\u0442\u0443\u0441 \u0412\u0430\u0448\u0435\u0433\u043e \u043d\u043e\u0432\u043e\u0433\u043e \u0434\u0435\u043f\u043e\u0437\u0438\u0442\u0430 \u043d\u0438\u0436\u0435."},deposit_history:{title:"\u0418\u0441\u0442\u043e\u0440\u0438\u044f \u043f\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u044f",number:"#",identification:"\u0418\u0434\u0435\u043d\u0442\u0438\u0444\u0438\u043a\u0430\u0446\u0438\u043e\u043d\u043d\u044b\u0439 \u043a\u043e\u0434",time:"\u0412\u0440\u0435\u043c\u044f",txid:"\u041d\u043e\u043c\u0435\u0440 \u043f\u0435\u0440\u0435\u0432\u043e\u0434\u0430",confirmations:"\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0435\u043d\u0438\u044f",from:"\u041e\u0442",amount:"\u0421\u0443\u043c\u043c\u0430",cancel:"\u043e\u0442\u043c\u0435\u043d\u0438\u0442\u044c",no_data:"\u041d\u0435\u0442 \u0438\u0441\u0442\u043e\u0440\u0438\u0447\u0435\u0441\u043a\u0438\u0445 \u0434\u0430\u043d\u043d\u044b\u0445",canceled:"\u041e\u0442\u043c\u0435\u043d\u0435\u043d",submitted:"\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0435\u043d",accepted:"\u041f\u0440\u0438\u043d\u044f\u0442",rejected:"\u041e\u0442\u043a\u043b\u043e\u043d\u0435\u043d"},withdraw_fiat:{title:"\u0412\u044b\u0432\u0435\u0441\u0442\u0438 \u0432 {{currency}}",intro:"\u0412\u044b\u0431\u0435\u0440\u0438\u0442\u0435 \u0431\u0430\u043d\u043a \u0434\u043b\u044f \u0432\u044b\u0432\u043e\u0434\u0430 \u0441\u0440\u0435\u0434\u0441\u0442\u0432 \u0438 \u0432\u0432\u0435\u0434\u0438\u0442\u0435 \u043d\u043e\u043c\u0435\u0440 \u0441\u0447\u0435\u0442\u0430.",intro_2:"\u0418\u043c\u044f \u0432\u043b\u0430\u0434\u0435\u043b\u044c\u0446\u0430 \u0431\u0430\u043d\u043a\u043e\u0432\u0441\u043a\u043e\u0433\u043e \u0441\u0447\u0435\u0442\u0430 \u0434\u043e\u043b\u0436\u043d\u043e \u0441\u043e\u0432\u043f\u0430\u0434\u0430\u0442\u044c \u0441 \u0412\u0430\u0448\u0438\u043c \u0438\u043c\u0435\u043d\u0435\u043c.",attention:"\u0427\u0430\u0441\u044b \u0440\u0430\u0431\u043e\u0442\u044b: \u0441 9:00 \u0434\u043e 18:00",withdraw_address:"\u0410\u0434\u0440\u0435\u0441 \u0432\u044b\u0432\u043e\u0434\u0430",balance:"\u0411\u0430\u043b\u0430\u043d\u0441",withdraw_amount:"\u0421\u0443\u043c\u043c\u0430 \u0432\u044b\u0432\u043e\u0434\u0430",min:"\u041a\u0430\u043a \u043c\u0438\u043d\u0438\u043c\u0443\u043c",withdraw_all:"\u0412\u044b\u0432\u0435\u0441\u0442\u0438 \u0432\u0441\u0435"},withdraw_coin:{title:"\u0412\u044b\u0432\u0435\u0441\u0442\u0438 {{currency}}",intro:'\u041f\u043e\u0436\u0430\u043b\u0443\u0439\u0441\u0442\u0430 \u0432\u0432\u0435\u0434\u0438\u0442\u0435 \u0430\u0434\u0440\u0435\u0441 \u0438 \u0441\u0443\u043c\u043c\u0443, \u0437\u0430\u0442\u0435\u043c \u043d\u0430\u0436\u043c\u0438\u0442\u0435 "\u041e\u0442\u043f\u0440\u0430\u0432\u0438\u0442\u044c". \u0417\u0430\u044f\u0432\u043a\u0430 \u0431\u0443\u0434\u0435\u0442 \u043f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0435\u043d\u0430 \u0432 \u0442\u0435\u0447\u0435\u043d\u0438\u0435 10 \u043c\u0438\u043d\u0443\u0442',label:"\u042f\u0440\u043b\u044b\u043a",balance:"\u0411\u0430\u043b\u0430\u043d\u0441",amount:"\u0421\u0443\u043c\u043c\u0430",min:"\u041a\u0430\u043a \u043c\u0438\u043d\u0438\u043c\u0443\u043c",withdraw_all:"\u0412\u044b\u0432\u0435\u0441\u0442\u0438 \u0432\u0441\u0435"},withdraw_history:{title:"\u0418\u0441\u0442\u043e\u0440\u0438\u044f \u0432\u044b\u0432\u043e\u0434\u0430",number:"\u0427\u0438\u0441\u043b\u043e",withdraw_time:"\u0412\u0440\u0435\u043c\u044f",withdraw_account:"\u0421\u0447\u0435\u0442 \u0432\u044b\u0432\u043e\u0434\u0430",withdraw_address:"\u0410\u0434\u0440\u0435\u0441",withdraw_amount:"\u0421\u0443\u043c\u043c\u0430",actual_amount:"\u0422\u0435\u043a\u0443\u0449\u0438\u0439 \u043e\u0441\u0442\u0430\u0442\u043e\u043a",fee:"\u041a\u043e\u043c\u0438\u0441\u0441\u0438\u044f",miner_fee:"\u041a\u043e\u043c\u0438\u0441\u0441\u0438\u044f",cancel:"\u041e\u0442\u043c\u0435\u043d\u0430",no_data:"\u041d\u0435\u0442 \u0438\u0441\u0442\u043e\u0440\u0438\u0447\u0435\u0441\u043a\u0438\u0445 \u0434\u0430\u043d\u043d\u044b\u0445",submitted:"\u041f\u043e\u0434\u0433\u043e\u0442\u043e\u0432\u043b\u0435\u043d\u043e",prepared:"\u041f\u043e\u0434\u0433\u043e\u0442\u043e\u0432\u043b\u0435\u043d\u043e",rejected:"\u041e\u0442\u043a\u043b\u043e\u043d\u0435\u043d\u043e",accepted:"\u041f\u0440\u0438\u043d\u044f\u0442\u043e",processing:"\u041e\u0431\u0440\u0430\u0431\u0430\u0442\u044b\u0432\u0430\u0435\u0442\u0441\u044f",succeed:"\u0413\u043e\u0442\u043e\u0432\u043e",confirmed:"\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0435\u043d",canceled:"\u041e\u0442\u043a\u043b\u043e\u043d\u0435\u043d\u043e",failed:"\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c"}}}},I18n.locale="ru";