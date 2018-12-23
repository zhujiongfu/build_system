#include<iostream>
#include<string>
 
using namespace std;
 
class Student
{
	public:
		Student(int , string, float);
		void display();
	protected:
		int num;
		string name;
		float score;	
};
Student::Student(int n, string na, float s)
{
	num=n;
	name=na;
	score=s;
}
void Student::display()
{
	cout<<"num:"<<num<<"\nname:"<<name<<"\nscore:"<<score<<endl;
}
class Graduate:public Student
{
	public:
			Graduate(int , string , float, float);
			void display();
 
	private:
			float pay;
	
};
Graduate::Graduate(int n, string na, float s, float p):Student(n,na,s),pay(p)
{
}
void Graduate::display()
{
	cout<<"num:"<<num<<"\nname:"<<name<<"\nscore:"<<score<<"\npay:"<<pay<<endl;
 }
 
int main()
{
	Student stud1(110,"SDL",99.8);
	Graduate grad1(120,"CCT",88.9, 250.5);
	
	Student *p;
	
	p=&stud1;
	cout<<"student:"<<endl;
	p->display();
	p=&grad1;
	cout<<"graduate:"<<endl;
	p->display();
	
	return 0;
} 
