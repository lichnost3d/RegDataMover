﻿&НаКлиенте
Перем ФормаРедактированияЗапроса Экспорт; //Хранит ссылку на форму редактора запросов

#Область ОбработчикиСобытийФормы

// Процедура - Обработчик события "ПриСозданииНаСервере" формы
//
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбновитьСписокРегистров();
	
КонецПроцедуры // ПриСозданииНаСервере()

// Процедура - Обработчик события "ПередЗагрузкойДанныхИзНастроекНаСервере" формы
//
&НаСервере
Процедура ПередЗагрузкойДанныхИзНастроекНаСервере(Настройки)
	
	Если Настройки["ВыгружаемыеДвижения"] = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекЭлемент Из Настройки["ВыгружаемыеДвижения"] Цикл
		
		Если ТекЭлемент.Пометка Тогда
			Продолжить;
		КонецЕсли;
		
		ТекРегистр = ВыгружаемыеДвижения.НайтиПоЗначению(ТекЭлемент.Значение);
		
		Если ТекРегистр = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ТекРегистр.Пометка = Ложь;
		
	КонецЦикла;
	
	Настройки.Удалить("ВыгружаемыеДвижения");
	
КонецПроцедуры // ПередЗагрузкойДанныхИзНастроекНаСервере()

// Процедура - Обработчик события "ПриОткрытии" формы
//
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВремНомерФайла = ПолучитьНомерФайла(ПутьКФайлу);
	Если ВремНомерФайла = Неопределено Тогда
		НомерПервогоФайла = 1;
	Иначе
		НомерПервогоФайла = ВремНомерФайла;
	КонецЕсли;
	
	ФормаРедактированияЗапроса();
	
	ОбновитьСписокКолонокЗапроса();
	
КонецПроцедуры // ПриОткрытии()

// Процедура - Обработка оповещения формы
//
&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИзмененыНастройки" И Параметр = ЭтаФорма Тогда
		ОбновитьСписокКолонокЗапроса();
	КонецЕсли;
	
КонецПроцедуры // ОбработкаОповещения()

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

// Процедура - обработка начала выбора файла
//
&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Диалог = Новый ДиалогВыбораФайла(?(Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.ГруппаВыгрузка,
	                                   РежимДиалогаВыбораФайла.Сохранение,
									   РежимДиалогаВыбораФайла.Открытие));
									   
	Диалог.Фильтр = "Файл выгрузки / загрузки (*.json)|*.json";
	Диалог.Заголовок = "Файл выгрузки / загрузки";

	ЗавершениеВыбораФайла = Новый ОписаниеОповещения("ПутьКФайлуНачалоВыбораЗавершение", ЭтаФорма);
	
	Диалог.Показать(ЗавершениеВыбораФайла);
	
КонецПроцедуры // ПутьКФайлуНачалоВыбора()

// Процедура - продолжение обработки выбора файла
//
&НаКлиенте
Процедура ПутьКФайлуНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если НЕ ТипЗнч(ВыбранныеФайлы) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыбранныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ПутьКФайлу = ВыбранныеФайлы[0];
	
	ВремНомерФайла = ПолучитьНомерФайла(ПутьКФайлу);
	Если ВремНомерФайла = Неопределено Тогда
		НомерПервогоФайла = 1;
	Иначе
		НомерПервогоФайла = ВремНомерФайла;
	КонецЕсли;
	
КонецПроцедуры // ПутьКФайлуНачалоВыбораЗавершение()

#КонецОбласти

#Область ПроцедурыВыгрузкиЗагрузкиДвижений

// Функция - Возвращает движения документов в формате JSON
//
// Параметры:
//  ТекущийИндекс     - Число     - индекс начального элемента списка документов для обработки
//                                  (реквизита формы СписокДокументов)
// 
// Возвращаемое значение:
//	Строка        - движения документов в формате JSON
//
&НаСервере
Функция ПолучитьДвиженияНаСервере(ТекущийИндекс)
	
	ДанныеДляСохранения = Новый Массив();
	
	Обработано = 0;
	
	// обработка списка документов начиная с указанного идекса 
	Для й = ТекущийИндекс По СписокДокументов.Количество() - 1 Цикл							 
		
		ТекЭлементДок = СписокДокументов.Получить(й);
		
		Если НЕ ТекЭлементДок.Пометка Тогда
			Продолжить;
		КонецЕсли;
			
		ДокОбъект = ТекЭлементДок.Значение.ПолучитьОбъект();
		
		// подготовка списка регистров, движения которых будут выгружены
		СписокРегистров = Новый Массив();
		
		Для Каждого ТекЭлемент Из ВыгружаемыеДвижения Цикл
			
			Если НЕ ТекЭлемент.Пометка Тогда
				Продолжить;
			КонецЕсли;
			
			СписокРегистров.Добавить(ТекЭлемент.Значение);
			
		КонецЦикла;
		
		СтруктураДвижений = ПреобразованиеДанных().ДвиженияДокументаВСтруктуру(ДокОбъект, СписокРегистров);
		
		ДанныеДокумента = Новый Структура("Ссылка, Движения", ПреобразованиеДанных().ЗначениеВСтруктуру(ДокОбъект.Ссылка), СтруктураДвижений);
		
		ДанныеДляСохранения.Добавить(ДанныеДокумента);
		
		Обработано = Обработано + 1;
		
		// отсечка по количеству объектов в одном файле
		Если КоличествоДокументовВФайле > 0 И Обработано >= КоличествоДокументовВФайле Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	ТекущийИндекс = й;
		
	Возврат ПреобразованиеДанных().ЗаписатьОписаниеОбъектаВJSON(ДанныеДляСохранения);
	
КонецФункции // ПолучитьДвиженияНаСервере()

// Процедура - Выполняет загрузку движений документов
//
// Параметры:
//  ДанныеСтрокой         - Строка        - движения документов в формате JSON
//
&НаСервере
Процедура ЗагрузитьДвиженияНаСервере(ДанныеСтрокой)
	
	ДанныеДляЗагрузки = ПреобразованиеДанных().ПрочитатьОписаниеОбъектаИзJSON(ДанныеСтрокой);
	
	Для Каждого ТекДокумент Из ДанныеДляЗагрузки Цикл
		
		ДокСсылка = ПреобразованиеДанных().ЗначениеИзСтруктуры(ТекДокумент.Ссылка);
		
		Если ДокСсылка = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ДокОбъект = ДокСсылка.ПолучитьОбъект();
		
		ПреобразованиеДанных().ДвиженияДокументаИзСтруктуры(ДокОбъект, ТекДокумент.Движения);
		
		Для Каждого ТекНабор Из ТекДокумент.Движения Цикл
			Попытка
				ДокОбъект.Движения[ТекНабор.Ключ].ОбменДанными.Загрузка = Истина;
				ДокОбъект.Движения[ТекНабор.Ключ].Записать();
			Исключение
				ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				ТекстСообщения = "Не удалось записать движения документа """ + СокрЛП(ДокСсылка) + """: " + Символы.ПС;
				Сообщить(ТекстСообщения + ТекстОшибки);
			КонецПопытки;
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры // ЗагрузитьДвиженияНаСервере()

#КонецОбласти

#Область ОбработкаКоманд

// Процедура - Заполняет список документов по указанным настройкам процессора запрососв
//
// Параметры:
//  НастройкиПолученияДанных   - Структура           - настройки процессора запросов
//		*Запрос_Текст               - Строка              - текст запроса
//		*Запрос_Параметры           - Массив (Структура)  - таблица параметров запроса
//		*ПроизвольныеВыражения      - Массив (Структура)  - таблица произвольных функций
//
&НаСервере
Процедура ЗаполнитьСписокДокументовНаСервере(НастройкиПолученияДанных)
	
	СписокДокументов.Очистить();
	
	ТекстОшибки = "";
	
	Попытка
		РезультатЗапроса = ПроцессорЗапросов().ВыполнитьЗапрос(НастройкиПолученияДанных.Запрос_Текст
															, ПреобразованиеДанных().ЗначениеИзСтруктуры(НастройкиПолученияДанных.Запрос_Параметры)
															, 
															, ПреобразованиеДанных().ЗначениеИзСтруктуры(НастройкиПолученияДанных.ПроизвольныеВыражения)
															, 
															, Ложь
															, ТекстОшибки);
	Исключение
		ТекстОшибки = "Ошибка запроса 1С: ";
		ТекстОшибки = ТекстОшибки + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
		
	Если НЕ ПустаяСтрока(ТекстОшибки) Тогда
		ТекстОшибки = "Ошибка запроса 1С: " + ТекстОшибки;
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
		
	Если РезультатЗапроса.Пустой() Тогда
		Сообщить("Запрос не вернул результатов!");
		Возврат;
	КонецЕсли;
		
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ТекСсылка = СписокДокументов.ТипЗначения.ПривестиЗначение(Выборка[КолонкаЗапроса]);
		Если НЕ ЗначениеЗаполнено(ТекСсылка) Тогда
			Продолжить;
		КонецЕсли;
		СписокДокументов.Добавить(Выборка[КолонкаЗапроса]);
	КонецЦикла;
		
КонецПроцедуры // ЗаполнитьСписокДокументовНаСервере()

// Процедура - Обработчик команды команды "ЗагрузитьДвижения"
//
&НаКлиенте
Процедура ЗаполнитьСписокДокументов(Команда)
	
	НастройкиПолученияДанных = ФормаРедактированияЗапроса().ПолучитьЗапросСПараметрами();

	ЗаполнитьСписокДокументовНаСервере(НастройкиПолученияДанных);
	
КонецПроцедуры // ЗаполнитьСписокДокументов()

// Процедура - Обработчик команды команды "СохранитьДвижения"
//
&НаКлиенте
Процедура СохранитьДвижения(Команда)
	
	СчетчикФайлов = НомерПервогоФайла;
	
	ТекущийИндекс = 0;
	
	Пока ТекущийИндекс <= СписокДокументов.Количество() - 1 Цикл
		
		ВремФайл = Новый Файл(ПутьКФайлу);
		
		ИмяФайла = ВремФайл.Путь + ПолучитьИмяФайлаБезНомера(ПутьКФайлу) + Формат(СчетчикФайлов, "ЧГ=0") + ВремФайл.Расширение;
		
		ДанныеДляСохранения = ПолучитьДвиженияНаСервере(ТекущийИндекс);
	
		Текст = Новый ТекстовыйДокумент();
		Текст.УстановитьТекст(ДанныеДляСохранения);
		Текст.НачатьЗапись(, ИмяФайла, КодировкаТекста.UTF8);
	
		СчетчикФайлов = СчетчикФайлов + 1;
		
		ТекущийИндекс = ТекущийИндекс + 1;
		
	КонецЦикла;
	
КонецПроцедуры // СохранитьДвижения()

// Процедура - Обработчик команды команды "ЗагрузитьДвижения"
//
&НаКлиенте
Процедура ЗагрузитьДвижения(Команда)
	
	СчетчикФайлов = НомерПервогоФайла;
	
	ВремФайл = Новый Файл(ПутьКФайлу);
	Путь = ВремФайл.Путь;
	Имя = ПолучитьИмяФайлаБезНомера(ВремФайл);
	Расширение = ВремФайл.Расширение;
	
	Пока Истина Цикл
		ТекПутьКФайлу = Путь + Имя + Формат(СчетчикФайлов, "ЧГ=0") + ВремФайл.Расширение;
		
		ВремФайл = Новый Файл(ТекПутьКФайлу);
		
		Если НЕ ВремФайл.Существует() Тогда
			Прервать;
		КонецЕсли;
		
		ДопПараметры = Новый Структура("ТекстДанных, ПутьКФайлу", Новый ТекстовыйДокумент(), ТекПутьКФайлу);
	
		ОбработкаЧтенияФайла = Новый ОписаниеОповещения("ЗагрузитьДвиженияЗавершение", ЭтотОбъект, ДопПараметры);
	
		ДопПараметры.ТекстДанных.НачатьЧтение(ОбработкаЧтенияФайла, ТекПутьКФайлу, КодировкаТекста.UTF8);
	
		СчетчикФайлов = СчетчикФайлов + 1;
	КонецЦикла;	
	
КонецПроцедуры // ЗагрузитьДвижения()

// Процедура - Завершение обработки команды команды "ЗагрузитьДвижения"
//
&НаКлиенте
Процедура ЗагрузитьДвиженияЗавершение(ДополнительныеПараметры) Экспорт
	
	ЗагрузитьДвиженияНаСервере(ДополнительныеПараметры.ТекстДанных.ПолучитьТекст());
	
КонецПроцедуры // ЗагрузитьДвиженияЗавершение()

// Процедура - Обработчик команды "РедактироватьЗапрос" - открывает редактор запроса
//
&НаКлиенте
Процедура РедактироватьЗапрос(Команда)
	
	ФормаРедактированияЗапроса().Открыть();
	
КонецПроцедуры //РедактироватьЗапрос()

#КонецОбласти

#Область СлужебныеПроцедуры

// Функция - Получает обработку процессора запросов
// 
// Возвращаемое значение:
//		ВнешняяОбработкаОбъект - обработка процессора запросов
//
&НаСервере
Функция ПроцессорЗапросов() Экспорт
	
	Попытка
		Возврат ВнешниеОбработки.Создать("ктв_ПроцессорЗапросов");
	Исключение
		ПодключитьВнешнююОбработкуПоИмени("ктв_ПроцессорЗапросов");
	КонецПопытки;
	
	Возврат ВнешниеОбработки.Создать("ктв_ПроцессорЗапросов");
	
КонецФункции // ПроцессорЗапросов()

// Функция - Получает форму редактирования запросов
// 
// Возвращаемое значение:
//		УправляемаяФорма - Форма редактирования запроса
//
&НаКлиенте
Функция ФормаРедактированияЗапроса() Экспорт
	
	Если ФормаРедактированияЗапроса = Неопределено Тогда
		ПодключитьВнешнююОбработкуПоИмени("ктв_ПреобразованиеДанных");
		
		ИмяОбработки = ПодключитьВнешнююОбработкуПоИмени("ктв_ПроцессорЗапросов");
		ФормаРедактированияЗапроса = ПолучитьФорму(СтрШаблон("ВнешняяОбработка.%1.Форма.Форма", ИмяОбработки), , ЭтаФорма);
	КонецЕсли;
	
	Возврат ФормаРедактированияЗапроса;
	
КонецФункции // ФормаРедактированияЗапроса()

// Функция - Получает обработку сериализации значений
// 
// Возвращаемое значение:
//		ВнешняяОбработкаОбъект - обработка преобразования данных
//
&НаСервере
Функция ПреобразованиеДанных() Экспорт
	
	Попытка
		Возврат ВнешниеОбработки.Создать("ктв_ПреобразованиеДанных");
	Исключение
		ПодключитьВнешнююОбработкуПоИмени("ктв_ПреобразованиеДанных");
	КонецПопытки;
	
	Возврат ВнешниеОбработки.Создать("ктв_ПреобразованиеДанных");
	
КонецФункции // ПреобразованиеДанных()

// Функция - ищет внешнюю обработку по указанному имени рядом с текущей и подключает ее
// возвращает имя подключенной обработки
//
// Параметры:
//  ИмяОбработки         - Строка        - имя внешней обработки
// 
// Возвращаемое значение:
//  ВнешняяОбработкаОбъект        - внешняя обработка
// 
&НаСервере
Функция ПодключитьВнешнююОбработкуПоИмени(ИмяОбработки)
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	ФайлЭтойОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	
	ПутьКОбработке = ФайлЭтойОбработки.Путь + ИмяОбработки + ФайлЭтойОбработки.Расширение;
	
	ОписаниеЗащиты = Новый ОписаниеЗащитыОтОпасныхДействий();
	ОписаниеЗащиты.ПредупреждатьОбОпасныхДействиях = Ложь;
	
	АдресОбработки = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ПутьКОбработке), ЭтотОбъект.УникальныйИдентификатор);
	
	Возврат ВнешниеОбработки.Подключить(АдресОбработки, ИмяОбработки, Ложь, ОписаниеЗащиты);
	
КонецФункции // ПодключитьВнешнююОбработкуПоИмени()

// Процедура - Обновляет список колонок запроса для выбора
//
&НаКлиенте
Процедура ОбновитьСписокКолонокЗапроса()
	
	Элементы.КолонкаЗапроса.СписокВыбора.Очистить();
	
	КолонкиЗапроса = ФормаРедактированияЗапроса().ПолучитьКолонкиЗапроса();
	
	Для Каждого ТекКолонка Из КолонкиЗапроса Цикл
		Элементы.КолонкаЗапроса.СписокВыбора.Добавить(ТекКолонка.Имя);
	КонецЦикла;
	
КонецПроцедуры // ОбновитьСписокКолонокЗапроса()

// Процедура - Обновляет список выгружаемых регистров
//
&НаСервере
Процедура ОбновитьСписокРегистров()
	
	ВыгружаемыеДвижения.Очистить();
	
	Для Каждого ТекРегистр Из Метаданные.РегистрыСведений Цикл
		Если ТекРегистр.РежимЗаписи = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.Независимый Тогда
			Продолжить;
		КонецЕсли;
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр сведений: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	Для Каждого ТекРегистр Из Метаданные.РегистрыНакопления Цикл
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр накопления: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	Для Каждого ТекРегистр Из Метаданные.РегистрыБухгалтерии Цикл
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр бухгалтерии: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	Для Каждого ТекРегистр Из Метаданные.РегистрыРасчета Цикл
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр расчета: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	ВыгружаемыеДвижения.СортироватьПоПредставлению();
	
КонецПроцедуры // ОбновитьСписокРегистров()

// Функция - Возвращает завершающую, цифровую часть имени файла (расширение не учитывается)
//
// Параметры:
//  ПутьКФайлу         - Строка, Файл     - путь к файлу или файл для получения номера
// 
// Возвращаемое значение:
//   Число, Неопределено    - номер файла, (Неопределено - имя файла оканчивается не на цифру)
//
&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьНомерФайла(Знач ПутьКФайлу)
	
	ИмяФайла = "";
	Если ТипЗнч(ПутьКФайлу) = Тип("Файл") Тогда
		ИмяФайла = ИмяФайла.ИмяБезРасширения;
	Иначе
		ВремФайл = Новый Файл(ПутьКФайлу);
		ИмяФайла = ВремФайл.ИмяБезРасширения;
	КонецЕсли;
	
	НомерФайла  = "";
	
	НомерСимвола = СтрДлина(ВремФайл.ИмяБезРасширения);
		
	Пока Истина Цикл
		
		Если НомерСимвола = 0 Тогда
			Прервать;
		КонецЕсли;
		
		ТекСимвол = Сред(ИмяФайла, НомерСимвола, 1);
		Если Найти("0123456789", ТекСимвол) = 0 Тогда
			Прервать;
		КонецЕсли;
		
		НомерФайла = ТекСимвол + НомерФайла;
		
		НомерСимвола = НомерСимвола - 1;
		
	КонецЦикла;
	
	Если ПустаяСтрока(НомерФайла) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Возврат Число(НомерФайла);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции // ПолучитьНомерФайла()

// Функция - Возвращает имя файла без завершающей, цифровой части (расширение не учитывается)
//
// Параметры:
//  ПутьКФайлу         - Строка, Файл     - путь к файлу или файл для получения имени
// 
// Возвращаемое значение:
//   Строка    - имя файла без завершающих цифр
//
&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИмяФайлаБезНомера(Знач ПутьКФайлу)
	
	ИмяФайла = "";
	Если ТипЗнч(ПутьКФайлу) = Тип("Файл") Тогда
		ИмяФайла = ПутьКФайлу.ИмяБезРасширения;
	Иначе
		ВремФайл = Новый Файл(ПутьКФайлу);
		ИмяФайла = ВремФайл.ИмяБезРасширения;
	КонецЕсли;
	
	НомерФайла = ПолучитьНомерФайла(ИмяФайла);
	
	Если НомерФайла = Неопределено Тогда
		Возврат ИмяФайла;
	Иначе
		Возврат Сред(ИмяФайла, 1, СтрДлина(ИмяФайла) - СтрДлина(Формат(НомерФайла, "ЧГ=0")));
	КонецЕсли;
	
КонецФункции // ПолучитьИмяФайлаБезНомера()

#КонецОбласти

