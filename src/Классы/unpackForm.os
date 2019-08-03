#Использовать logos
#Использовать "./internal/v8unpack"

Перем ВерсияПлагина;
Перем Лог;
Перем Обработчик;
Перем КомандыПлагина;

Перем ВыполнятьПереименованиеModule;
Перем ВыполнятьПереименованиеForm;
Перем Распаковщик;


#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.0.5";
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 0;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Плагин добавляет функциональность распаковки обычных форм на исходники";
КонецФункции

// Возвращает подробную справку к плагину 
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Справка плагина";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "unpackForm";
КонецФункции 

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.plugins.unpackForm";
КонецФункции

#КонецОбласти

#Область Подписки_на_события

Процедура ПриАктивизации(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;
	ВыполнятьПереименованиеModule = Ложь;
	ВыполнятьПереименованиеForm = Ложь;

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт

	Лог.Отладка("Ищу команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);
	
	КлассРеализации.Опция("R rename-module", Ложь, "[*unpackForm] переименование module -> module.bsl")
						.Флаг()
						.ВОкружении("GITSYNC_RENAME_MODULE");

	КлассРеализации.Опция("F rename-form", Ложь, "[*unpackForm] переименование form -> form.txt")
						.Флаг()
						.ВОкружении("GITSYNC_RENAME_FORM");

КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды) Экспорт

	ВыполнятьПереименованиеModule = ПараметрыКоманды.Параметр("rename-module", Ложь);
	ВыполнятьПереименованиеForm = ПараметрыКоманды.Параметр("rename-form", Ложь);

КонецПроцедуры

Процедура ПередПеремещениемВКаталогРабочейКопии(Конфигуратор, КаталогРабочейКопии, КаталогВыгрузки, ПутьКХранилищу, НомерВерсии) Экспорт
	
	СписокФайлов = НайтиФайлы(КаталогВыгрузки, "Form.bin", Истина);
	Лог.Отладка("Найдено файлов form.bin: <%1> шт.", СписокФайлов.Количество());

	Если СписокФайлов.Количество() > 0 Тогда
		
		Распаковщик = Новый РаспаковкаФорм;
		
	КонецЕсли;

	Для Каждого ФайлФормы Из СписокФайлов Цикл

		НовыйКаталог = Новый Файл(ФайлФормы.Путь);
		
		КаталогФормы = ОбъединитьПути(НовыйКаталог.ПолноеИмя, ФайлФормы.ИмяБезРасширения);
		СоздатьКаталог(КаталогФормы);

		РаспаковатьКонтейнерМетаданных(ФайлФормы.ПолноеИмя, КаталогФормы);

	КонецЦикла;

КонецПроцедуры

#КонецОбласти

// хитрость: надо выносить в отдельную процедуру, 
// а сборку мусора делать в другом кадре стека вызовов.
// иначе сборка ничего не соберет
//
Процедура dllРаспаковать(Знач ФайлРаспаковки, Знач КаталогРаспаковки)
		
	Распаковщик = Новый ЧтениеФайла8(ФайлРаспаковки);
	Распаковщик.ИзвлечьВсе(КаталогРаспаковки, Истина);
	ОсвободитьОбъект(Распаковщик); // почему-то этого недостаточно. Вопрос к реализации компоненты.
	Распаковщик = Неопределено;
	
КонецПроцедуры

Процедура РаспаковатьКонтейнерМетаданных(Знач ФайлРаспаковки, Знач КаталогРаспаковки)

	Распаковщик.Распаковать(ФайлРаспаковки, КаталогРаспаковки);

	Если ВыполнятьПереименованиеModule Тогда
		ПереименованиеModule(КаталогРаспаковки);
	КонецЕсли;

	Если ВыполнятьПереименованиеForm Тогда
		ПереименованиеForm(КаталогРаспаковки);
	КонецЕсли;

КонецПроцедуры

Процедура ПереименованиеModule(КаталогРаспаковки)

	Для Каждого ФайлМодуля Из НайтиФайлы(КаталогРаспаковки, "module", Истина) Цикл

		СтароеИмяФайла = ФайлМодуля.ПолноеИмя;
		НовоеИмяФайла = ОбъединитьПути(ФайлМодуля.Путь, "Module.bsl");
		
		Лог.Отладка("Конвертирую наименование файла <%1> --> <%2>", СтароеИмяФайла, НовоеИмяФайла);
		КопироватьФайл(СтароеИмяФайла, НовоеИмяФайла);
		УдалитьФайлы(СтароеИмяФайла);
		
	КонецЦикла;

КонецПроцедуры

Процедура ПереименованиеForm(КаталогРаспаковки)

	Для Каждого ФайлФормы Из НайтиФайлы(КаталогРаспаковки, "form", Истина) Цикл

		СтароеИмяФайла = ФайлФормы.ПолноеИмя;
		НовоеИмяФайла = ОбъединитьПути(ФайлФормы.Путь, "form.txt");
		
		Лог.Отладка("Конвертирую наименование файла <%1> --> <%2>", СтароеИмяФайла, НовоеИмяФайла);
		КопироватьФайл(СтароеИмяФайла, НовоеИмяФайла);
		УдалитьФайлы(СтароеИмяФайла);
		
	КонецЦикла;

КонецПроцедуры

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");

КонецПроцедуры

Инициализация();
