import 'dart:io';

void main()
{
	print("Hello World!");

	String? string = stdin.readLineSync();
	string ??= "Nothing!\n";

	print(string);
}
