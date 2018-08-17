import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;




//////////////////////////////
//*****input: # of topic that declared in model-final.twords
// data set without label and with number of document in first line(File1)
//
//
//
//**** output:
//topictermMatrix.txt = semantic Graph with #num_semTerm term
//merged= HashMap that store merged graph
//unionedTerms.txt= union of semantic and co-occurrence terms
//topicFeatureVector.txt= final topics feature vectors.
//relationMatafterpruning2.txt= co-occurrence matrix after pruning 2
//merged.txt= merged matrix.
////////////////////////////

public class Main {
	public static HashMap<String, ArrayList<Double>> termTopicMap = new HashMap<String, ArrayList<Double>>();
	public static HashMap<String,ArrayList<Double>> SemanticGraph=new HashMap<String,ArrayList<Double>>();
	//public static HashMap<String,ArrayList<Double>>CoGraphMap=new HashMap <String,ArrayList<Double>>();
	static ArrayList<String> unioned= new ArrayList<String>();
	//public static ArrayList<String> documentTerms= new ArrayList<String>();
	public static BasicGraph mergedGraph=new BasicGraph();
	//public static int[][] dataGraph;
	 	  // static int[][] datamatrix;
	//public static int[][] transpose;
	//public static int[][] link_frequency;
	public  double[][] relationMatrix;
	public static ArrayList<String> semanticTerm;
	//public   ArrayList<String> coTerms;
	//public static ArrayList<String> coTerms2;
	public static int[] indexes;
	//public  HashMap<String,ArrayList<Double>> merged=new HashMap<String,ArrayList<Double>>();
	//public  HashMap <Integer,double[]>topicVectors=new HashMap<Integer,double[]>();
	public static HashMap <Integer,double[]>topVecFinal=new HashMap<Integer,double[]>();
	//public  int[] capacity;
	public static int docNo;
	static DecimalFormat df = new DecimalFormat("#0.0");
	static DecimalFormat dfForSemanticRelation = new DecimalFormat("#0.000000");
	//0.9-0.5=3 topic
	//1 , 0.5=3 topic
	//parameters:
	/**
	 * 
	 */
	public static int num_semTerm=28;
	static int threshold=5;
	
	public static double link_relation=1;
	public static int linkFrequnecyParameter=25;
	
	static boolean pruneAfterMerge=true;
	//private  ArrayList<String> documentTerms;
	//private static Graph mergedGraph;
	
	
	
	public static void main(String[]args) throws Exception {
		
		
//		String dataset="toy/";
//		int topicNo=3;
//		docNo=6;
//		int docTermSize=11;
//		String FileNameCoMatrix="toy/toy-co.txt";
//		String FileNameTerms="toy/toy-terms.txt";
//		String FileNameDocTermMatrix="toy/docTermMatrixToy.txt";
//		String datasetName="toy/toy.txt";
//		String ldaMoldel="toy/model-final.twords.toy";
//		String docTfIdfMatrix="toy/toy-tfidf.txt";
//		String FileNameTF="toy/toy-tf.txt";

		
//		
		String dataset="webkb/";
		int topicNo=4;
		docNo=1383;
		int docTermSize=4568;
		String FileNameDocTermMatrix="webkb/docTermMatrixWebkb.txt";
		String FileNameTF="webkb/webkb-tf.txt";
		String datasetName="webkb/webkbcleaned.txt";
		String ldaMoldel="webkb/model-final.twords.webkb";
		String docTfIdfMatrix="webkb/webkb-tfidf.txt";
		String FileNameCoMatrix="webkb/webkb-co2.txt";	
		String FileNameTerms="webkb/webkb-terms.txt";
		

//		String dataset="tdt/";
//		int topicNo=30;
//		docNo=9394;
//		int docTermSize=33446;
//		String FileNameCoMatrix="tdt/TDT-co22.txt";
//		String FileNameTerms="tdt/TDT-terms.txt";
//		//String FileNameDocTermMatrix="tdt/docTermMatrixToy.txt";
//		String datasetName="tdt/TDT.txt";
//		String ldaMoldel="tdt/model-final.twords.tdt";
//		String docTfIdfMatrix="tdt/TDT-tfidf.txt";
//		String FileNameTF="tdt/TDT-tf.txt";
		
		
		long starttotal=System.currentTimeMillis();
		//String str = "some";
		//long noBytes = MemoryUtil.memoryUsageOf(topicVectors);
		//System.out.println(MemoryUtil.memoryUsageOf(topicVectors));
//		double i5=4538.5;
//		System.out.println(MemoryUtil.memoryUsageOf(i5));
	
		 ArrayList<String> documentTerms = documentTermsExtractor(docTermSize,FileNameTerms);
		int docno=docNo;
		
		int[] capacity=capacityCalculator(docTermSize, FileNameTF,docno);
	
		LinkedHashMap<ArrayList<Integer>, Integer> linkfrequency2 = linkFrequenctCalculator(FileNameCoMatrix, docTermSize);
		//int[][] linkfrequency = null;
		double[] relationMatrix=ralationMatrixCalculator(capacity, FileNameTF, linkfrequency2, datasetName, documentTerms);
		
		try
		{
			PrintWriter writer = new PrintWriter(dataset+num_semTerm+"-"
		    		+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"RelationGraphWebKb.txt", "UTF-8");
		    Set<ArrayList<Integer>> keyset = linkfrequency2.keySet();
		    List keylist = new ArrayList(keyset);
		    for (int i1=0;i1<relationMatrix.length;++i1)
		    {
		    	if (relationMatrix[i1]>0)
		    	{
		    	writer.println(keylist.get(i1)+" "+relationMatrix[i1]);
		    	}
		    }
		    writer.close();
		}
		
		catch(Exception e)
		{
			System.out.println(e);
		}
		try{
		
		Graph relationGraphBeforePruning2 = new Graph(docTermSize);
		//@SuppressWarnings("unused")
		//connectedComponent g2=new connectedComponent(docTermSize);
		
		for (int i=0;i<relationMatrix.length;++i)
		{
			//for (int j=0;j<=i;++j)
			//{
				if (relationMatrix[i]!=0)
				{
					Set<ArrayList<Integer>> keys = linkfrequency2.keySet();
	  			 	Object[] keyarray = keys.toArray();
	  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
	  			 	
	  			 	int term_i_int = x.get(0);
	  			 	int term_j_int = x.get(1);
					relationGraphBeforePruning2.addEdge(term_i_int, term_j_int);
				//	g2.addEdge(i, j);
				}
			//}
		}
		
		System.out.println("------------------");
		//System.out.println("bridges in relation graph are: ");
		ArrayList<String> bridgeEdges = relationGraphBeforePruning2.bridge();
		//System.out.println("end of bridgs in co graph.");
		System.out.println("number of bridge in co graph="+(bridgeEdges).size());
		if ((bridgeEdges).size()==0)
		{System.out.println("There is no Bridge Edge in co-graph");}
		else
		{	//HashMap<ArrayList<Integer>,Integer> linkfrequency_hashmap = link_freq_hashmap(FileNameCoMatrix, docTermSize);
			Set<ArrayList<Integer>> keySet = linkfrequency2.keySet();
			List keyList = new ArrayList(keySet);
			for (int i=0;i<bridgeEdges.size();++i)
			{	
			
				String Edge=bridgeEdges.get(i);
				String[] node=Edge.split(" ");
				int k=0;
				//System.out.println(node[0]+","+node[1]);
				if (Integer.parseInt(node[0])>Integer.parseInt(node[1]))
						{

							ArrayList<Integer>temp=new ArrayList<Integer>();
							temp.add(Integer.parseInt(node[0]));
							temp.add(Integer.parseInt(node[1]));
							int index=keyList.indexOf(temp);
							relationMatrix[index]=0;
						}
				else
				{

					ArrayList<Integer>temp=new ArrayList<Integer>();
					temp.add(Integer.parseInt(node[1]));
					temp.add(Integer.parseInt(node[0]));
					int index=keyList.indexOf(temp);
					relationMatrix[index]=0;
				}
				//System.out.println("bridge "+i+" done of "+bridgeEdges.size());
			}
		}
		
		System.out.println("pruning 2 done!");
		}
		catch(Exception e)
		{System.out.println(e);}
		
		ArrayList<String> finalSemTerm=new ArrayList<String>();
	try{
		BufferedReader ldaMoldelReader = new BufferedReader(new FileReader(new File(ldaMoldel)));


		HashMap<Integer, ArrayList<String>> topicTermMap = new HashMap<Integer, ArrayList<String>>();
		HashMap<Integer, ArrayList<String>> topWordsPerTopic = new HashMap<Integer, ArrayList<String>>();
		HashMap<String,ArrayList<Double>> semantic=new HashMap<String,ArrayList<Double>>();
		ArrayList<String> CandidateTerm=new ArrayList<String>();
	
	
		
		
		for (int i=0 ; i<topicNo;++i)
		{
			ArrayList<String> terms1=new ArrayList<String>();
			@SuppressWarnings("unused")
			String topicName=ldaMoldelReader.readLine();
			
			
			for (int j=0;j<docTermSize;++j)
			{
				ArrayList<Double> x = new ArrayList<Double>();
				 String []CurrentTerm2=ldaMoldelReader.readLine().split("\t");
				 //System.out.println(i+","+j+","+CurrentTerm2[0]);
				 String[]CurrentTerm3=CurrentTerm2[1].split(" ");
				 
				
				 terms1.add(CurrentTerm2[1]);
						 
				 if (termTopicMap.get(CurrentTerm3[0])==null)
				 {
					 for (int k=0;k<topicNo;++k)
					 {
						 
						 x.add(k,0.0);
					 }
					 termTopicMap.put(CurrentTerm3[0], x);
					 
						
				 }
				 x=termTopicMap.get(CurrentTerm3[0]);
				 x.set(i, Double.parseDouble(CurrentTerm3[1]));
				 
				 termTopicMap.put(CurrentTerm3[0],x);
				 topicTermMap.put(i, terms1);
			}
		}
		
		
		
		for (int i=0;i<topicNo;++i)
		{
			ArrayList<String> topWords=new ArrayList<String>();
			ArrayList<String> candidate = topicTermMap.get(i);
			String topwordwithprob = candidate.get(0);
			String[] topword1=topwordwithprob.split(" ");
			topWords.add(topword1[0]);
			if (!(CandidateTerm.contains(topword1[0])))
			{
			CandidateTerm.add(topword1[0]);
		}
			double topprob=Double.parseDouble(topword1[1]);
			
			for (int j=1;j<docTermSize;++j)
			{
				String newterm = candidate.get(j);
				String[] newtopword=newterm.split(" ");
				double currentprob=Double.parseDouble(newtopword[1]);
				if (currentprob>=(topprob/threshold))//Threshold for top word setting.
				{
					topWords.add(newtopword[0]);
					if (!(CandidateTerm.contains(newtopword[0])))
					{
					CandidateTerm.add(newtopword[0]);
					}
				}
				 if (currentprob<(topprob/threshold)) 
				{
				break;
				}
				
			}
			topWordsPerTopic.put(i, topWords);
			
			
			
			
		}
		
		
/////////////////////////refine top word per topic hash map/////////////////////////////////
		
for (int ii=0;ii<topicNo;++ii)
{
for (int jj=ii+1;jj<topicNo;++jj)
{
	ArrayList<String> first=topWordsPerTopic.get(ii);
	ArrayList<String> second=topWordsPerTopic.get(jj);
	int sizefirst=first.size();
	int sizesecond=second.size();
	if (sizefirst>=sizesecond)
	{
	HashSet<String> set1 = new HashSet<String>();
	
    for(String iii:first ){
        set1.add(iii);
    }
    
    HashSet<String> set2 = new HashSet<String>();
    for(String iii: second){
        if(set1.contains(iii)){
            set2.add(iii);
        }
    }
    String[] result = new String[set2.size()];
    int iii=0;
    for(String n: set2){
        result[iii++] = n;
    }
    
    if(result.length>0)
	{
		//System.out.println("topic"+ii+"and topic "+jj+"have common words:"+result[0]);
		
		for (int i=0;i<result.length;++i)
		{
			ArrayList<Double> commonword=termTopicMap.get(result[i]);
			if (commonword.get(ii)>commonword.get(jj))
			{
				ArrayList <String> x=topWordsPerTopic.get(jj);
				x.remove(result[i]);
				topWordsPerTopic.put(jj, x);
			}
			if (commonword.get(ii)<=commonword.get(jj))
			{
				ArrayList <String> x=topWordsPerTopic.get(ii);
				x.remove(result[i]);
				topWordsPerTopic.put(ii, x);
			}
			
			
		}
	}
    
	}
	if (sizefirst<sizesecond)
	{
		HashSet<String> set1 = new HashSet<String>();
		
	    for(String iii:second ){
	        set1.add(iii);
	    }
	    
	    HashSet<String> set2 = new HashSet<String>();
	    for(String iii: first){
	        if(set1.contains(iii)){
	            set2.add(iii);
	        }
	    }
	    String[] result = new String[set2.size()];
	    int iii=0;
	    for(String n: set2){
	        result[iii++] = n;
	    }
	    
		if(result.length>0)
		{
			//System.out.println("topic"+ii+"and topic "+jj+"have common words:"+result[0]);
			for (int i=0;i<result.length;++i)
			{
				ArrayList<Double> commonword=termTopicMap.get(result[i]);
				if (commonword.get(ii)>commonword.get(jj))
				{
					ArrayList <String> x=topWordsPerTopic.get(jj);
					x.remove(result[i]);
					topWordsPerTopic.put(jj, x);
				}
				if (commonword.get(ii)<=commonword.get(jj))
				{
					ArrayList <String> x=topWordsPerTopic.get(ii);
					x.remove(result[i]);
					topWordsPerTopic.put(ii, x);
				}
				
				
			}
		}
	}
	

}
}


//////////////////////end of refine top word per topic/////////////////////////////////////////
		
		///////////////////////semantic term calculation    ///////////////////////
		
		for (int i=0;i<CandidateTerm.size();++i)
		{
			String candid=CandidateTerm.get(i);
			ArrayList<Double> relations=new ArrayList<Double>();
			ArrayList<Double> topicDistributionOfterm= termTopicMap.get(CandidateTerm.get(i));
			int TopicNoOfCandid=0;
			for (int j=0;j<topWordsPerTopic.size();++j)
			{
				ArrayList<String> termInTopic = topWordsPerTopic.get(j);
				if (termInTopic.contains(candid))
				{
					TopicNoOfCandid=j;
					break;
				}
				else
					continue;
			}
				double ptz=topicDistributionOfterm.get(TopicNoOfCandid);
				double sigmaptz=0;
				for (int k=0;k<topicNo;++k)
				{
					sigmaptz=sigmaptz+topicDistributionOfterm.get(k);
				}
			relations.add(ptz*(Math.log(ptz/sigmaptz)/(Math.log(2))));
			//relations.add(ptz*(Math.log(ptz/sigmaptz)));
			//}
			semantic.put(candid,relations);
		}
	//}
	//////////////////////////////////////////////////////////////////////////////////	
		
//		Double[] arr = new Double[CandidateTerm.size()];
//		int iii=0;
//		for (int j=0;j<CandidateTerm.size();++j)
//		{
//			String x=CandidateTerm.get(j);
//			double max=-Double.MAX_VALUE;
//			for (int k=0;k<topicNo;++k)
//			{
//				
//				if ((semantic.get(x)).get(k)>max)
//					max=(semantic.get(x)).get(k);
//					
//					
//				
//			}
//			arr[iii]=(max);
//			iii++;
//		}
		
		HashMap<String,Double> semantic23=new HashMap <String,Double>();
		
		for(int i=0;i<semantic.size();++i)
		{
			semantic23.put(CandidateTerm.get(i), semantic.get(CandidateTerm.get(i)).get(0));
		}
//	
		LinkedHashMap<String, Double> semanticWords = sortHashMapByValues(semantic23);
		System.out.println("number of candidate term="+CandidateTerm.size());
		//indexes = indexesOfTopElements(arr,CandidateTerm.size());

			
		
		
		 semanticTerm=new ArrayList<String>();
//		for (int j=0;j<indexes.length;++j)
//		{
//			String x=CandidateTerm.get(indexes[j]);
//			
//			
//				semanticTerm.add(x);
//			
//			
//			
//		}
		 
		 
		System.out.print("SematicTerms Are: "); 
		Set<String> semanticTerms = semanticWords.keySet();
		finalSemTerm=new ArrayList<String>(semanticTerms);
		
		if (num_semTerm>finalSemTerm.size())
		{
			num_semTerm=finalSemTerm.size();
		}
		for (int f=0;f<num_semTerm;++f)
		{
			System.out.print(finalSemTerm.get(f)+" ");
			
		}
		System.out.println();

		//System.out.println("\n"+"<<<<<<<<Done>>>>>>>>");
		
		//////////////////////////////////creating matrix//////////////////////////////////
		
		int [][]matrixSemantic=new int [topicNo][num_semTerm];
		//HashMap<String,ArrayList<Double>> SemanticGraph=new HashMap<String,ArrayList<Double>>();
		
			try{
			    PrintWriter writer = new PrintWriter(dataset+num_semTerm+"-"
			    		+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"topictermMatrix.txt", "UTF-8");
			    
			    for (int i1=0;i1<num_semTerm;++i1)
			    {
			    	writer.print(finalSemTerm.get(i1)+" ");
			    }
			    writer.println();
			    for (int i2=0;i2<topicNo;++i2)
		    	{ 
			    	writer.print((i2+1)+" ");
			    	for (int i1=0;i1<num_semTerm;++i1)
			    	{
			    	
			    		if (topWordsPerTopic.get(i2).contains(finalSemTerm.get(i1)))
			    		{
			    			writer.print("1"+" ");
			    			matrixSemantic[i2][i1]=1;
			    		}
			    		if (!(topWordsPerTopic.get(i2).contains(finalSemTerm.get(i1))))
			    		{
			    			writer.print("0"+" ");
			    			matrixSemantic[i2][i1]=0;
			    		}
			    	}
			    	writer.println();
			     
		    	}
			    writer.close();
		    	int[][] transpose1 = new int[num_semTerm][topicNo];
		        for (int i1 = 0; i1 < matrixSemantic.length; i1++)
		        {
		            for (int j = 0; j < matrixSemantic[0].length; j++)
		            {
		                transpose1[j][i1] = matrixSemantic[i1][j];
		            }
		        }
		        
		        int [][] result = new int[num_semTerm][num_semTerm];

		        /* Loop through each and get product, then sum up and store the value */
		        for (int i1 = 0; i1 < num_semTerm; i1++) { 
		            for (int j = 0; j < num_semTerm; j++) { 
		                for (int k = 0; k <transpose1[0].length; k++) { 
		                    result[i1][j] += transpose1[i1][k]*matrixSemantic[k][j]  ;
		                }
		            }
		        }
		        
		        for (int i1=0;i1<num_semTerm;++i1)//CandidateTerm.size()>
		        {
		        	ArrayList<Double> currentrow=new ArrayList<Double>();
		        	for (int i11 = 0; i11 < num_semTerm; i11++) 
		        	{ 
			            
			            	currentrow.add((double) result[i1][i11]);
			            
		        	}
		        	SemanticGraph.put(finalSemTerm.get(i1), currentrow);
			     }
				
		        
			
			} catch (IOException e) {
			   // do something
			}
			
		
		System.out.println("TopicTerm Matrix extracted.");
		/////////////////////////////////////////////////////////////////////////////////////


	}
	catch(Exception e)
	{System.out.println(e);}
	 ArrayList<String> semanticRelation= new ArrayList<String>();
	try{
		ArrayList<Integer> coIndex=new ArrayList<Integer>();
		for (int i=0;i<relationMatrix.length;++i)
		{
			if (relationMatrix[i]!=0)
			{
				coIndex.add(i);
			}
				
		}
		
		
		HashSet<String>coTermsTemp=new HashSet<String>();
		Set<ArrayList<Integer>> keys = linkfrequency2.keySet();
	 	Object[] keyarray = keys.toArray();
		for (int i=0;i<coIndex.size();++i)
		{
			
			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[coIndex.get(i)];
			 	
			 	int term_i_int = x.get(0);
			 	int term_j_int = x.get(1);
			coTermsTemp.add(documentTerms.get(term_i_int));
			coTermsTemp.add(documentTerms.get(term_j_int));
		}
		 
		
		
		//////////////////////
		
		
			// int[][] semanticRelation=new int[(int) Math.pow(semanticTerm.size(),2)][2];
			 try{
			 PrintWriter writerSemanticGraph = new PrintWriter(dataset+num_semTerm+"-"
						+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"edge-list-semanticGraph-names.txt", "UTF-8");
			 int lineNo=0;
			 for (int i2=0;i2<num_semTerm;++i2)
		    	{ 
				 for (int j=i2+1;j<num_semTerm;++j)
				 {
					 if (SemanticGraph.get(finalSemTerm.get(i2)).get(j)>0)
					 {
			    		//writer3.println(i2+","+j);
					 	writerSemanticGraph.println(finalSemTerm.get(i2)+","+finalSemTerm.get(j));
					 	//semanticRelation[lineNo][0]=
					 			int term_i=documentTerms.indexOf(finalSemTerm.get(i2));
					 	//semanticRelation[lineNo][1]=
					 			int term_j=documentTerms.indexOf(finalSemTerm.get(j));
					 			
					 			if (term_i<term_j)
					 			{
					 				//semanticRelation[lineNo][0]=term_j;
					 				//semanticRelation[lineNo][1]=term_i;
					 				semanticRelation.add(term_j+" "+term_i);
					 			}
					 			else 
					 			{
					 				//semanticRelation[lineNo][0]=term_i;
					 				//semanticRelation[lineNo][1]=term_j;
					 				semanticRelation.add(term_i+" "+term_j);
					 			}
					 			
					 			
					 	lineNo++;
					 }
			    		
				 }
			    	
				 
			     
		    	}
			 writerSemanticGraph.close();
			 }
			 catch(Exception e)
			 {
				 System.out.println(e);
			}
		/////////////////////////
		 ArrayList<String> coTerms = coTermMethod(coTermsTemp);
		 for (int i=0;i<num_semTerm;++i)
		 {
			 semanticTerm.add(finalSemTerm.get(i));
		 }
		 unioned=(ArrayList<String>) union(coTerms, semanticTerm);
	}
	catch(Exception e)
	{
		System.out.println(e);
	}
		
		 try{
			 PrintWriter writer = new PrintWriter(dataset+num_semTerm+"-"
						+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"unionedTerms.txt", "UTF-8");
			 for (int i=0;i<unioned.size();++i)
			 {
				 String term=unioned.get(i);
				 writer.println(term);
			 }
			 writer.close();
		 }
		 catch(Exception e)
		 {
			 
		 }
		 
		 
		System.out.println("unioned list created!");
		HashMap<String, ArrayList<Double>> merged = new HashMap<String, ArrayList<Double>>();
	//	try{
		long startMerging=System.currentTimeMillis();
		merged = merging(relationMatrix, semanticRelation,documentTerms,linkfrequency2);
		long endmerging=System.currentTimeMillis();
		System.out.println("\ntwo graph merged in: "+(endmerging-startMerging)+" ms");
		//}
		//catch(Exception e)
		//{
		//	System.out.println(e);
		//}
			
			try{
			    PrintWriter writer = new PrintWriter(dataset+num_semTerm+"-"
			    		+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"MergedGraph.txt", "UTF-8");
			    writer.print("\t\t");
			    for (int i1=0;i1<unioned.size();++i1)
			    {
			    	writer.print(unioned.get(i1)+" ");
			    }
			    writer.println();
			    for (int i2=0;i2<unioned.size();++i2)
		    	{ 
			    	writer.print(unioned.get(i2)+"\t");
			    	
			    		writer.println(merged.get(unioned.get(i2)));
			    		
			    	
			    	//writer.println();
			     
		    	}
			    writer.close();
			} catch (IOException e) {
			   // do something
			}
		//	long statrtgc=System.currentTimeMillis();
			//System.gc();
			//long endfc=System.currentTimeMillis();
		//	System.out.println("time to do gc ="+(endfc-statrtgc));
			
			///////////////////////////////////////////edge list of merged graph////////////////////
			//PrintWriter writer3 = new PrintWriter(dataset+link_relation+"-"+linkFrequnecyParameter+"-"+"edge-list-mergedGraph.txt", "UTF-8");
			try{
			PrintWriter writer31 = new PrintWriter(dataset+num_semTerm+"-"
					+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"edge-list-mergedGraph-names.txt", "UTF-8");
			 for (int i2=0;i2<unioned.size();++i2)
		    	{ 
				 for (int j=i2+1;j<unioned.size();++j)
				 {
					 if (merged.get(unioned.get(i2)).get(j)>0)
					 {
			    		//writer3.println(i2+","+j);
					 	writer31.println(unioned.get(i2)+","+unioned.get(j));
					 }
			    		
				 }
			    	//writer.println();
			     
		    	}
			 
			 //writer3.close();
			 writer31.close();
			}
			catch(Exception e)
			{
				System.out.println(e);
			}
			 ////////////////////////////////////////////////////
			
			 
			
			//////////////////////////////////////////////////
				//relationGraphBeforePruning2=null;
				
				//System.gc();
			int finaltopicno=0;
			try{
			Graph g1 = new Graph(unioned.size());
			connectedComponent g21=new connectedComponent(unioned.size());
			for (int i=0;i<unioned.size();++i)
			{
				for (int j=i+1;j<unioned.size();++j)
				{
					if ((merged.get(unioned.get(i)).get(j))!=0)
					{
						g1.addEdge(i,j);
					
						mergedGraph.addEdge(i,j);
					
					}
				}
			}
			System.out.println("------------------");
			ArrayList<String> bridgeEdges = g1.bridge();
			System.out.println("number of bridge in merged graph="+(bridgeEdges).size());
			if (pruneAfterMerge)
			{
				if ((bridgeEdges).size()==0)
				{System.out.println("There is no Bridge Edge in merged-graph");}
				else
				{	
					for (int i=0;i<bridgeEdges.size();++i)
					{
						String Edge=bridgeEdges.get(i);
						String[] node=Edge.split(" ");
						//if (Integer.parseInt(node[0])>Integer.parseInt(node[1]))
						//{
							ArrayList<Double> current=merged.get(unioned.get(Integer.parseInt(node[0])));
							current.set((Integer.parseInt(node[1])),0.0);
							merged.put(unioned.get(Integer.parseInt(node[0])), current);
							 current=merged.get(unioned.get(Integer.parseInt(node[1])));
							current.set((Integer.parseInt(node[0])),0.0);
						//}
						
					}
				}
			}
			for (int i=0;i<unioned.size();++i)
			{
				for (int j=i+1;j<unioned.size();++j)
				{
					if ((merged.get(unioned.get(i)).get(j))!=0)
					{
						//g1.addEdge(i, j);
						g21.addEdge(i, j);
						//mergedGraph.addEdge(i,j);
						
					}
				}
			}
			
			System.out.println("Conected components are:");	
			g21.printSCCs();
			HashMap<Integer, ArrayList<Integer>> stronglyConnectedComponents = connectedComponent.componenet;
			int count=0;
			for (int i=0;i<stronglyConnectedComponents.size();++i)
			{
				ArrayList<Integer> ithComponents = stronglyConnectedComponents.get(i);
				if (ithComponents.size()>1)
				{
					count++;
					System.out.print(count+")");
					for (int j=0;j<ithComponents.size();++j)
					{
						System.out.print(unioned.get(ithComponents.get(j))+" ");
					}
					System.out.println();
				}
				
			}
			
			System.out.println("------------------");
			int finalComponentSize=connectedComponent.componenet.size();
			System.out.println("connected component size:"+finalComponentSize);
			System.out.println("------------------");
			
			
			
			
			//HashMap <Integer,double[]>topicVectors=new HashMap<Integer,double[]>();
			HashMap<Integer, double[]> topicVectors = topicVectorsMethpd(documentTerms, merged, finalComponentSize);
			
			
		//	@SuppressWarnings("unused")
		//	double[] topic_vector = topicVectors.get(0);
			
			
			
			for (int i=0;i<finalComponentSize;++i)
			{
				
				topVecFinal.put(i,finalTopicFeatureVector(topicVectors,documentTerms,(connectedComponent.componenet.get(i)),i));
				
			}
			
			
			double[] topic_vector_final = topVecFinal.get(0);
			
			PrintWriter writer = new PrintWriter(dataset+num_semTerm+"-"
					+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"topicFeatureVector.txt", "UTF-8");
			for (int i=0;i<finalComponentSize;++i)
			{
				
				double size=0;
				double[] currentFeatureVector = topVecFinal.get(i);
				for (int j=0; j<currentFeatureVector.length;++j)
				{
					size=size+currentFeatureVector[j];
				}
				if (size>0.0)
				{	StringBuffer outputLine = new StringBuffer();
					for (int j=0;j<currentFeatureVector.length;++j)
					{
						
						outputLine.append(currentFeatureVector[j]+" ");
					}
					writer.println(outputLine);
					++finaltopicno;
				}
				
			}
			writer.close();
			
			System.out.println("final topic feature vector extracted.");

			//System.out.println("Done");
			
			long endtotal=System.currentTimeMillis();
			System.out.println("*************************************");
			System.out.println("Total runTime= "+(endtotal-starttotal));
			}
			catch (Exception e)
			{
				System.out.println(e);
			}
			
			///////////////////////////////////////////////

			
		//cosine similarity
			
			
		BufferedReader brDocTermMat = new BufferedReader(new FileReader(new File(docTfIdfMatrix)));
		String currentLine = brDocTermMat.readLine();
	      currentLine = brDocTermMat.readLine();
		 currentLine = brDocTermMat.readLine();
		String[] terms = currentLine.split(" ");
		int tf_idf_lines_no=Integer.parseInt(terms[2]);
		//ArrayList<String> docTfIdfMAtrixTerms=new ArrayList<String>(unioned.size());
		HashMap <Integer,double[]>documentTfIdfVectors=new HashMap <Integer,double[]>();
		for (int i=0;i<tf_idf_lines_no;++i)
		{
			currentLine = brDocTermMat.readLine();
			String[] terms1 = currentLine.split(" ");
			int doc_id=Integer.parseInt(terms1[0])-1;
			int term_id=Integer.parseInt(terms1[1])-1;
			double weight=Double.parseDouble(terms1[2]);
			String term_string=documentTerms.get(term_id);
			double[] currentDocWeight=new double[unioned.size()];
			
				if (unioned.contains(term_string))
				{
					int term_index_in_unioned=unioned.indexOf(term_string);
					double[] temp=documentTfIdfVectors.get(doc_id);
					if (temp==null)
					{
						temp=new double[unioned.size()];
					}
					temp[term_index_in_unioned]=weight;
					documentTfIdfVectors.put(doc_id, temp);
				}	
				
			
			
		}
		
		
		BufferedReader brDocTermMat1 = new BufferedReader(new FileReader(new File(dataset+num_semTerm+"-"
				+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"topicFeatureVector.txt")));
		//currentLine=brDocTermMat.readLine();
		HashMap <Integer,ArrayList<Double>>topicVectors=new HashMap <Integer,ArrayList<Double>>();
		for (int i=0;i<finaltopicno;++i)
		{
			String currentLine1 = brDocTermMat1.readLine();
			String[] terms1 = currentLine1.split(" ");
			ArrayList<Double> vector=new ArrayList<Double>(docTermSize);
			for (int j=0;j<unioned.size();++j)
			{
				vector.add(Double.parseDouble((terms1[j])));
			}
			topicVectors.put(i, vector);
		}
		brDocTermMat1.close();
		
		//double max_value=0;
	//int max_index=0;
		int[] results=new int [docNo];
		for (int i=0; i<docNo;++i)
		{
			double max_value=0;
			int max_index=0;
			//d=bordare doc i as matrix;
			double[]document=documentTfIdfVectors.get(i);
			if (document==null)
			{
				document=new double[unioned.size()];
			}
//			double[] document=new double[docTermSize];
//			for(int l=0;l<d1.length;++l)
//			{
//				document[l]=d1[l];
//			}
			
			
			double sigma_similarity_all_topics=0.0;
			for (int j=0;j<topicVectors.size();++j)
			{
				ArrayList<Double>d2=topicVectors.get(j);
				double[] topic=new double[docTermSize];
				for(int l=0;l<d2.size();++l)
				{
					topic[l]=d2.get(l);
				}
				
				
				//z=bordare topic j as matrix
				 sigma_similarity_all_topics=sigma_similarity_all_topics+(1-similarity(document,topic));
				
			}
			for (int j=0;j<topicVectors.size();++j)
			{
				ArrayList<Double>d2=topicVectors.get(j);
				double[] topic=new double[docTermSize];
				for(int l=0;l<d2.size();++l)
				{
					topic[l]=d2.get(l);
				}
				
				
				//z=bordare topic j as matrix
				double sim=Math.sqrt(Math.pow(((1-similarity(document,topic))),2)/(sigma_similarity_all_topics));
				
				if (sim>max_value)
				{
				max_index=j;
				max_value= sim;
				}
			}
			results[i]=max_index;

		}
		PrintWriter writer2 = new PrintWriter(dataset+num_semTerm+"-"
				+threshold+"-"+link_relation+"-"+linkFrequnecyParameter+"-"+"result.txt", "UTF-8");
		PrintWriter writer3 = new PrintWriter(dataset+"result.txt", "UTF-8");
		for (int i=0 ;i<topicVectors.size();++i)
		{StringBuffer outputLineResult = new StringBuffer();
			for (int j=0;j<results.length;++j)
			{
				if (results[j]==(i))
				{
					outputLineResult.append(j+1+" ");
				}
			}
			writer2.println(outputLineResult);
			writer3.println(outputLineResult);
		}
		
		writer2.close();
		writer3.close();
		
		
		
	
		PrintWriter writer31 = new PrintWriter("C:\\Users\\Mostafa\\PycharmProjects\\HelloWorld\\"+"result.txt", "UTF-8");
	
			for (int j=0;j<results.length;++j)
			{
					writer31.println(results[j]);	
			}
			
		
		
		
		
		writer31.close();
		System.out.println("test log!!!!!!!!!!!!!!");
		//System.gc();
		//Runtime.getRuntime().exec(dataset+"Evaluation.exe", null, new File(dataset));
}

	private static ArrayList<String> coTermMethod(HashSet<String> coTermsTemp) {
		ArrayList<String> coTerms = new ArrayList<String>(coTermsTemp);
		return coTerms;
	}

	private static  HashMap <Integer,double[]> topicVectorsMethpd(ArrayList<String> documentTerms, HashMap<String, ArrayList<Double>> merged,
			int finalComponentSize) {
		HashMap <Integer,double[]> topicVectors=new HashMap <Integer,double[]>();
		for (int i=0;i<finalComponentSize;++i)
		{
			topicVectors.put(i,featureVectorOfTopics(documentTerms,connectedComponent.componenet.get(i),merged));
			
		}
		return topicVectors;
	}

	private static HashMap<ArrayList<Integer>, Integer> link_freq_hashmap(String fileNameCoMatrix, int docTermSize) 
			throws FileNotFoundException, IOException {
		BufferedReader CoMatrixReader = new BufferedReader(new FileReader(new File(fileNameCoMatrix)));
		String s=CoMatrixReader.readLine();
		int coRelationCount=Integer.parseInt(s);
		HashMap<ArrayList<Integer>, Integer> linkfrequency = new HashMap<ArrayList<Integer>, Integer>();		
		for (int i=0;i<coRelationCount;++i)
		{
			String[] coOccurrence=CoMatrixReader.readLine().split(",");
			ArrayList<Integer> temp=new ArrayList<Integer>();
			temp.add(Integer.parseInt(coOccurrence[0]));
			temp.add(Integer.parseInt(coOccurrence[1]));
			linkfrequency.put(temp, i);
			
		}
		CoMatrixReader.close();
		return linkfrequency;
	}

	private static  HashMap<String, ArrayList<Double>> merging(double[] relationMatrix, ArrayList<String> semanticRelation,ArrayList<String> documentTerms,LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2) throws Exception {
		 HashMap<String,ArrayList<Double>> merged=new HashMap<String,ArrayList<Double>>();
		 double[][] mergeMatrix=new double[unioned.size()][unioned.size()];
			Set<ArrayList<Integer>> keys = linkfrequency2.keySet();
		 	Object[] keyarray = keys.toArray();
		 for (int i=0;i<relationMatrix.length;++i)
		 {
			 ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
			 	
			 	int term_i_int = x.get(0);
			 	int term_j_int = x.get(1);
			 	String term_i_String=documentTerms.get(term_i_int);
				String term_j_String=documentTerms.get(term_j_int);
				int term_i_index_unioned=unioned.indexOf(term_i_String);
				int term_j_index_unioned=unioned.indexOf(term_j_String);
			if (relationMatrix[i]!=0)
			{
				mergeMatrix[term_i_index_unioned][term_j_index_unioned]=relationMatrix[i];
				mergeMatrix[term_j_index_unioned][term_i_index_unioned]=relationMatrix[i];
			}
		 }
		 
		 for (int i=0;i<semanticRelation.size();++i)
		 {
			String terms[]=semanticRelation.get(i).split(" ");
			int term_i=Integer.parseInt(terms[0]);
			int term_j=Integer.parseInt(terms[1]);
			String termi_string= documentTerms.get(term_i);
			String termj_string=documentTerms.get(term_j);
			
			int index_i=unioned.indexOf(termi_string);
			int index_j=unioned.indexOf(termj_string);
			
			 
			if (mergeMatrix[index_i][index_j]==0)
			{
				//System.out.println("semantic relation calculation required!");
				double pti=Collections.max(Main.termTopicMap.get(termi_string));
				double ptj=Collections.max(Main.termTopicMap.get(termj_string));
				double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
				mergeMatrix[index_i][index_j]=rSem;
				mergeMatrix[index_j][index_i]=rSem;
				
				
			}
		 }
		//multi object = new multi(semanticRelation,relationMatrix,documentTerms);
		//merged=object.merging();
		 for (int i=0;i<unioned.size();++i)
		 {
			 ArrayList<Double> line=new ArrayList<Double>(unioned.size());
			 for (int j=0;j<unioned.size();++j)
			 {
				 line.add(mergeMatrix[i][j]);
			 }
			 merged.put(unioned.get(i), line);
		 }
		return merged;
	}

	private static  ArrayList<String> documentTermsExtractor(int docTermSize,String FileNameTerms) throws IOException {
		
			ArrayList<String> documentTerms=new ArrayList<String>(docTermSize);
			BufferedReader brDocTermMat = new BufferedReader(new FileReader(new File(FileNameTerms)));
			String currentLine=brDocTermMat.readLine();
			String[] terms = currentLine.split(",");	
			for (String word : terms) 
			{
				word=word.replaceAll("\\s","");
				word=word.substring(2,word.length()-1);
				documentTerms.add(word);
				
			}
			brDocTermMat.close();
			return documentTerms;
	}

	private static double[] ralationMatrixCalculator(int[] capacity,String FileNameTF,LinkedHashMap<ArrayList<Integer>, Integer>linkfrequency,String datasetName,ArrayList<String> documentTerms) throws Exception {
		long start=System.currentTimeMillis();
		multi object=new multi(capacity);
		double[] relationMatrix = object.relation(FileNameTF,linkfrequency,datasetName,documentTerms);
		//object=null;
		long end=System.currentTimeMillis();
		System.out.println("Running time for relation extraction= "+(long)(end-start));
		return relationMatrix;
	}

	private static int[] capacityCalculator(int docTermSize,String FileNameTF,int docno) throws FileNotFoundException, IOException {
		
		int[][] datamatrix = dataMatricExtractor(docTermSize, FileNameTF);
		int[] capacity = new int[docno];
		//datamarix.length==row and datamatrix[0].length==col
		for (int i=0;i<datamatrix.length;++i)
		{
			capacity[(datamatrix[i][0])]=datamatrix[i][2]+capacity[(datamatrix[i][0])];
		}
		
	System.out.println("capacity calculated!");
	return capacity;
	}

	public static int[][] dataMatricExtractor(int docTermSize, String FileNameTF)
			throws FileNotFoundException, IOException {
		BufferedReader brDocTermMat;
		String currentLine;
		String[] terms;
		brDocTermMat = new BufferedReader(new FileReader(new File(FileNameTF)));
		currentLine=brDocTermMat.readLine();
		currentLine=brDocTermMat.readLine();
		String dataMatrixSize[]=brDocTermMat.readLine().split(" ");
		
		int[][] datamatrix = new int[Integer.parseInt(dataMatrixSize[2])][3];
		for (int i=0;i<Integer.parseInt(dataMatrixSize[2]);++i)
		{
			currentLine=brDocTermMat.readLine();
			terms = currentLine.split(" ");
			//for (int j=0;j<docTermSize;++j)
			//{
				datamatrix [i][0]=Integer.parseInt(terms[0])-1;
				datamatrix [i][1]=Integer.parseInt(terms[1])-1;
				datamatrix [i][2]=Integer.parseInt(terms[2]);
			//}
			
		}
		brDocTermMat.close();
		return datamatrix;
	}

	private static LinkedHashMap<ArrayList<Integer>,Integer> linkFrequenctCalculator(String FileNameCoMatrix, int docTermSize)
			throws FileNotFoundException, IOException {
		
		BufferedReader CoMatrixReader = new BufferedReader(new FileReader(new File(FileNameCoMatrix)));
		String s=CoMatrixReader.readLine();
		int coRelationCount=Integer.parseInt(s);
	
		LinkedHashMap<ArrayList<Integer>, Integer> linkfrequency = new LinkedHashMap<ArrayList<Integer>, Integer>();
		for (int i=0;i<coRelationCount;++i)
		{
			String[] coOccurrence=CoMatrixReader.readLine().split(",");
			int term_i = Integer.parseInt(coOccurrence[0]);
			int term_j = Integer.parseInt(coOccurrence[1]);
			//System.out.println(i);
			int frequency = Integer.parseInt(coOccurrence[2]);
			StringBuffer sBuffer = new StringBuffer();
			if (frequency>=Main.linkFrequnecyParameter)
			{
				ArrayList<Integer> temp=new ArrayList<Integer>();
				temp.add(term_i);
				temp.add(term_j);
				linkfrequency.put(temp, frequency);
		
			}

		}
		CoMatrixReader.close();
		return linkfrequency;
	}
	
	private static double similarity(double[] document, double[] topic) {
		// TODO Auto-generated method stub
		//double result=0;
		double soorat=0;
		double A=0;
		double B=0;
		for (int i=0;i<document.length;++i)
		{
			soorat=soorat+(document[i]*topic[i]);
			A=A+Math.pow(document[i],2);
			B=B+Math.pow(topic[i],2);
		}
		
		double makhraj=Math.sqrt(A)*Math.sqrt(B);
		return soorat/makhraj;
	}

//	public static int makhraj(int x) {
//		
//		int sum=0;
//		for (int ii=0;ii<docNo;++ii)
//		{
//			
//			if((datamatrix[ii][x]>0))
//			{
//				sum=sum+capacity[ii];
//			}
//		}
//		return sum;
//		
//	}
//	public static int soorat(int x, int y) {
//		
//		int sum=0;
//		for (int ii=0;ii<docNo;++ii)
//		{
//			if((datamatrix[ii][x]==1)&(datamatrix[ii][y]==1))
//			{
//				sum=sum+capacity[ii];
//			}
//		}
//		return sum;
//	}
	
	private static int[] indexesOfTopElements(Double[] arr, int i) {
		int[] result;
		Double[] copy =  Arrays.copyOf(arr,arr.length);
        Arrays.sort(copy);
        int diff=0;
        if (i>num_semTerm)
        {
        	//System.out.println("happpend");
        	diff=i-num_semTerm;
        	 result = new int[num_semTerm];
        }
        else
        {
        	 result = new int[i];
        }
        Double[] honey = Arrays.copyOfRange(copy,diff, copy.length);
        
        
        int resultPos = 0;
        for(int k = 0; k < arr.length; k++) {
            double onTrial = arr[k];
            int index = Arrays.binarySearch(honey,onTrial);
            if(index < 0) continue;
            if ((resultPos+1)>result.length) 
            {
            	result[--resultPos]=k;
            	continue;
            }
            result[resultPos++] = k;
        }
        return result;
    }
	
	private static  double[] featureVectorOfTopics(ArrayList<String> documentTerms,ArrayList<Integer> componentNodes, HashMap<String, ArrayList<Double>> merged ) 
	{
		double[] topicVector=new double [componentNodes.size()];
		for (int i=0;i<componentNodes.size();++i)
		{
			try{
			HashSet<Integer> neibors = BasicGraph.getNeighborhood(componentNodes.get(i));
			//HashSet<Integer> neibors = basic.getNeighborhood(componentNodes.get(i));
			ArrayList<Integer> neiborsArrayList=new ArrayList<Integer>(neibors);
			String term=unioned.get(componentNodes.get(i));
			double sumOfRelations=0.0;
			for (int j=0;j<neibors.size();++j)
			{
				//int neigbor_term = unioned.indexOf(documentTerms.get(neiborsArrayList.get(j)));
				//sumOfRelations=sumOfRelations+(merged.get(term)).get(neigbor_term);
				sumOfRelations=sumOfRelations+(merged.get(term)).get(neiborsArrayList.get(j));
				
			}
			topicVector[i]=Math.sqrt(neibors.size()*sumOfRelations);
			}
			catch(Exception e)
			{
				topicVector[i]=0.0;
			}
			
		}
		return topicVector;
    }
	
	private static double[] finalTopicFeatureVector(HashMap <Integer,double[]> topicVectors,ArrayList<String> docmentTerms,ArrayList<Integer> componentNodes, int topicNumber) 
	{
		double[] topicVectorFinal=new double [unioned.size()];
		for (int i=0;i<componentNodes.size();++i)
		{
			
			int node1=componentNodes.get(i);
			//String term=unioned.get(node1);
			//int node=docmentTerms.indexOf(term);
			double[] xxx=topicVectors.get(topicNumber);
			topicVectorFinal[node1]=xxx[i];
		}
		return topicVectorFinal;
    }
	
	
	public static LinkedHashMap<String, Double> sortHashMapByValues(
	        HashMap<String, Double> passedMap) {
	    List<String> mapKeys = new ArrayList<>(passedMap.keySet());
	    List<Double> mapValues = new ArrayList<>(passedMap.values());
	    Collections.sort(mapValues);
	    Collections.sort(mapKeys);

	    LinkedHashMap<String, Double> sortedMap =
	        new LinkedHashMap<>();

	    Iterator<Double> valueIt = mapValues.iterator();
	    while (valueIt.hasNext()) {
	        Double val = valueIt.next();
	        Iterator<String> keyIt = mapKeys.iterator();

	        while (keyIt.hasNext()) {
	            String key = keyIt.next();
	            Double comp1 = passedMap.get(key);
	            Double comp2 = val;

	            if (comp1.equals(comp2)) {
	                keyIt.remove();
	                sortedMap.put(key, val);
	                break;
	            }
	        }
	    }
	    return sortedMap;
	}
	
	
	public static <T> List<T> union(List<T> list1, List<T> list2) {
        Set<T> set = new HashSet<T>();

        set.addAll(list1);
        set.addAll(list2);

        return new ArrayList<T>(set);
    }

	
}
