#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <math.h>
using namespace std;

void print(vector<vector<double> > result);
void write_in_file(vector<vector<double> > result);
double calculate_variance(vector<double> scores);
double calculate_average(vector<double> scores);
double get_score(string line);
bool is_new_document(string line);
bool is_new_segment(string line);
bool starts_with(string mainStr, string toMatch);

const string FILE_NAME = "input.txt";

int main() {
  int noOfCurrentDoc = 1;
  vector<vector<double> > result;
  string line = "";
  ifstream infile;
  infile.open(FILE_NAME);

  // --- Read docID 1
  while ( true ) {
    getline(infile, line);
    if ( is_new_document(line) ) {
      noOfCurrentDoc ++;
      break;
    }
  }

  // this is only the variance of one doc. Each cell contains the variance of one segment.
  // size of it at the end will be the number of segments, queries in one document
  vector<double> currentDocResults;

  while( true ) {
    getline(infile, line);  // docID 2 segmentID 1

    if ( is_new_document(line) ) {
      result.push_back(currentDocResults);
      currentDocResults.clear();
      noOfCurrentDoc ++;
      continue;
    }

    // file has terminated
    if ( !is_new_segment(line) ) {
      // print(result);
      write_in_file(result);
      infile.close();
      return 0;
    }

    vector<double> scores; // scores for one query
    for (int i = 1; i < noOfCurrentDoc; i++) {
      getline(infile, line); // doc 1 -3.0617

      double score = get_score(line);
      scores.push_back(score);
    }
    double variance = calculate_variance(scores);
    currentDocResults.push_back(variance);
  }

}

void write_in_file(vector<vector<double> > result) {
  ofstream myfile;
  myfile.open("output.txt");
  for (int i = 0; i < result.size(); i++) {
    string docID = to_string(i + 2); // this +2 is beacuse docID 1 is ignored.
    string noOfSegments = to_string(result[i].size());
    myfile << "docID:" + docID + "-" + noOfSegments;

    for (int j = 0; j < result[i].size(); j++) {
      myfile << "-" + to_string(result[i][j]);
    }
    myfile << endl;
  }
  myfile.close();
}

// print on terminal
void print(vector<vector<double> > result) {
  for (int i = 0; i < result.size(); i++) {
    string docID = to_string(i + 2); // this +2 is beacuse docID 1 is ignored.
    string noOfSegments = to_string(result[i].size());
    cout << "docID:" + docID + "-" + noOfSegments;

    for (int j = 0; j < result[i].size(); j++) {
      cout << "-" + to_string(result[i][j]);
    }
    cout << endl;
  }
}

double calculate_variance(vector<double> scores) {
  double average = calculate_average(scores);
  double variance = 0;
  for (int i = 0; i < scores.size(); i++) {
    variance += pow(scores[i] - average , 2);
  }
  // cout << variance << endl << endl;
  return variance / double(scores.size());
}

double calculate_average(vector<double> scores) {
  double sum = 0;
  for (int i = 0; i < scores.size(); i++) {
    sum += scores[i];
  }
  return sum / double(scores.size());
}

// given a string: "doc 1 -3.0617", "-3.0617" is returned
double get_score(string line) {
  vector<string> parsed;
  istringstream iss(line);
  for(string s; iss >> s; ) {
    parsed.push_back(s);
  }
  return stod(parsed[parsed.size() - 1]);
}

bool is_new_document(string line) {
  return starts_with(line, "====");
}

bool is_new_segment(string line) {
  return starts_with(line, "docID");
}

bool starts_with(string mainStr, string toMatch) {
	// find returns 0 if toMatch is found at starting
	if(mainStr.find(toMatch) == 0)
		return true;
  return false;
}
