//============================================================================
// Name        : MixtureModelFeedback.cpp
// Author      : Mostafa
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <stdio.h>
#include <stdlib.h>
#include <Index.hpp>
#include <IndexManager.hpp>
#include <DocStream.hpp>
#include <BasicDocStream.hpp>
#include <OkapiRetMethod.hpp>
#include <ScoreAccumulator.hpp>
#include <SimpleKLRetMethod.hpp>
#include <UnigramLM.hpp>
#include <DocUnigramCounter.hpp>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <fstream>

using namespace std;
using namespace lemur;
using namespace api;
using namespace parse;
using namespace retrieval;

lemur::langmod::MLUnigramLM * negateTextQuery(Index &ind,
		lemur::api::DocIDSet &relDocs);

double klDivergence(lemur::langmod::MLUnigramLM *lm1,
		lemur::langmod::MLUnigramLM * lm2, Index * dbIndex) {

	double result = 0.0;
	TERMID_T termIdlm1;
	double qi;
	cout << "before start iteration on lm1" << endl;
	lm1->startIteration();
	while (lm1->hasMore()) {
		cout << "start iteration..... on lm1" << endl;
		lm1->nextWordProb(termIdlm1, qi);
		cout << dbIndex->term(termIdlm1) << "\t" << qi << endl;
		double pi = lm2->prob(termIdlm1);
		if (pi == 0)
			pi = 0.00000000000007;
		result += qi * log(qi / pi);
	}
	return result;

}
int main() {
	int counter = 0;
	Index *dbIndex;
	vector<lemur::langmod::MLUnigramLM *> languageModels;
	std::map<int, lemur::langmod::MLUnigramLM *> Lms;
	dbIndex = IndexManager::openIndex("index/index.key");
	cout << "index loaded." << endl;

	std::ifstream infile("test.txt");
	cout << "event data file loaded." << endl;

	std::string line;
	vector<string> agency_id;

	while (std::getline(infile, line)) {
		std::vector<string> cont;
		std::stringstream ss(line);
		std::string token;
		while (std::getline(ss, token, '-')) {
			cont.push_back(token);
		}

//		cout << cont[0] << endl; //agency
//		cout << cont[1] << endl; //id
//		cout << cont[2] << endl; //comment count

		agency_id.push_back(cont[1] + "_" + cont[0]);
		IndexedRealVector klResults;
		stringstream geek(cont[2]);
		int x = 0;
		geek >> x;
		for (int i = 0; i < x; i++) {
			std::stringstream ss;
			ss << i;
			std::string doc_id = cont[1] + "_" + cont[0] + "_" + ss.str();
//			cout << doc_id << endl;
			klResults.PushValue(dbIndex->document(doc_id), 1);
		}
		int size = klResults.size();
		cout << "count comment = " << x << " and count klresult = " << size
				<< endl;
		PseudoFBDocs *topDoc = new PseudoFBDocs(klResults, x, true);
		lemur::langmod::MLUnigramLM * res = negateTextQuery(*dbIndex, *topDoc);

		/*TERMID_T termId;
		 double val;
		 std::map<std::string, double> map;
		 res->startIteration();
		 int counter = 0;
		 double sumP = 0.0;
		 while (res->hasMore()) {
		 res->nextWordProb(termId, val);
		 sumP += val;
		 cout << counter++ << "\t" << dbIndex->term(termId) << "\t" << val
		 << endl;

		 }

		 cout<<"sum p lm ="<<sumP<<endl;
		 */

		cout << "done for doc id " + cont[1] << endl;

		languageModels.push_back(res);
		Lms[counter] = res;
//		Lms.find(0)->second->startIteration();
//		cout<<"start on "<<Lms.find(0)->second<<endl;
		counter++;
//		cout<<"vector size after push back"<<languageModels.size()<<endl;
//		lemur::langmod::MLUnigramLM* tmp;
//		tmp = languageModels[0];
//		cout<<"vector size after assign"<<languageModels.size()<<endl	;
//		tmp->startIteration();
//		TERMID_T termId;
//		double  val, sumP;
//		while (tmp->hasMore()) {
//			res->nextWordProb(termId, val);
//			sumP += val;
//			cout << dbIndex->term(termId) << "\t" << val << endl;
//		}
		//cout << languageModels.size() << endl;
		//delete res;
		//delete klResults;
		klResults.empty();

	}
	cout << "all lm saved in vector" << endl;
	cout << "array of lm size = " << languageModels.size() << endl;
	for (std::map<int, lemur::langmod::MLUnigramLM *>::iterator it =
			Lms.begin(); it != Lms.end(); ++it)
		std::cout << it->first << " => " << it->second << '\n';
	for (int i = 1; i < counter ; i++) {
		for (int j = 0; j < i; ++j) {
//			cout << i << j << endl;
			lemur::langmod::MLUnigramLM* lmi;
			//std::map<int ,  lemur::langmod::MLUnigramLM *>::iterator iterator;
			lmi = Lms.find(i)->second;
//			cout<<"lmi = "<<lmi<<endl;
			double result = 0.0;
			TERMID_T termIdlm1;
			double qi;
//			cout << "befor start iteration on lm1" << endl;
			lmi->startIteration();
//			cout << "after start iteration on lm1" << endl;
			while (lmi->hasMore()) {
//				cout << "start iteration..... on lm1" << endl;
				lmi->nextWordProb(termIdlm1, qi);
//				cout << dbIndex->term(termIdlm1) << "\t" << qi << endl;
				double pi = Lms.find(j)->second->prob(termIdlm1);
				if (pi == 0)
					pi = 0.000000000000000000000000007;
				result += qi * log(qi / pi);
			}
			cout << agency_id[i] + "," << agency_id[j] + "=" << result << endl;
		}

	}

	return 0;
}

lemur::langmod::MLUnigramLM * negateTextQuery(Index &ind,
		lemur::api::DocIDSet &relDocs) {
	lemur::langmod::DocUnigramCounter *collectLMCounter =
			new lemur::langmod::DocUnigramCounter(ind);
	lemur::langmod::UnigramLM *collectLM = new lemur::langmod::MLUnigramLM(
			*collectLMCounter, ind.termLexiconID());
	lemur::api::COUNT_T numTerms = ind.termCountUnique();

	lemur::langmod::DocUnigramCounter *dCounter =
			new lemur::langmod::DocUnigramCounter(relDocs, ind);

	double *distQuery = new double[numTerms + 1];
	double *distQueryEst = new double[numTerms + 1];

	double noisePr;

	int i;

	double meanLL = 1e-40;
	double distQueryNorm = 0;

	for (i = 1; i <= numTerms; i++) {
		distQueryEst[i] = rand() + 0.001;
		distQueryNorm += distQueryEst[i];
	}
	noisePr = 0.9; // TODO fb noise parameter

	int itNum = 50; // TODO max iteration count

	do {
		// re-estimate & compute likelihood
		double ll = 0;

		for (i = 1; i <= numTerms; i++) {

			distQuery[i] = distQueryEst[i] / distQueryNorm;
			// cerr « "dist: "« distQuery[i] « endl;
			distQueryEst[i] = 0;
		}

		distQueryNorm = 0;

		// compute likelihood
		dCounter->startIteration();
		while (dCounter->hasMore()) {
			int wd; //dmf FIXME
			double wdCt;
			dCounter->nextCount(wd, wdCt);
			ll += wdCt * log(noisePr * collectLM->prob(wd)  // Pc(w)
			+ (1 - noisePr) * distQuery[wd]); // Pq(w)
		}
		meanLL = 0.5 * meanLL + 0.5 * ll;
		if (fabs((meanLL - ll) / meanLL) < 0.0001) {
			cerr << "converged at " << 50 - itNum + 1 // TODO max iteration count
			<< " with likelihood= " << ll << endl;
			break;
		}

		// update counts

		dCounter->startIteration();
		while (dCounter->hasMore()) {
			int wd; // dmf FIXME
			double wdCt;
			dCounter->nextCount(wd, wdCt);

			double prTopic = (1 - noisePr) * distQuery[wd]
					/ ((1 - noisePr) * distQuery[wd]
							+ noisePr * collectLM->prob(wd));

			double incVal = wdCt * prTopic;
			distQueryEst[wd] += incVal;
			distQueryNorm += incVal;
		}
	} while (itNum-- > 0);

	lemur::utility::ArrayCounter<double> *lmCounter =
			new lemur::utility::ArrayCounter<double>(numTerms + 1);
	for (i = 1; i <= numTerms; i++) {
		if (distQuery[i] > 0) {
			lmCounter->incCount(i, distQuery[i]);
		}
	}

	lemur::langmod::MLUnigramLM *fblm = new lemur::langmod::MLUnigramLM(
			*lmCounter, ind.termLexiconID());

	delete collectLMCounter;
	delete collectLM;

	delete dCounter;
	delete[] distQuery;
	delete[] distQueryEst;

	return fblm;
}
