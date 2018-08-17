package fsdresultmaker;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;

public class ResultMaker {
	static DecimalFormat df = new DecimalFormat("#0.00000");
	public static void main(String[] args) throws IOException {
		
		int DocNumebr=240;
		int featureColumn = 4;//TF_IDF = 4 or TF = 5 or IDF = 6
		 String csvFile = "input/tag-computable-p2new.csv";
		 
		 FileWriter fw = new FileWriter("output/output-p2new-tfidf.csv");
	        BufferedWriter bw = new BufferedWriter(fw);
	        bw.write("theta,true-positive,false-alarm,miss-detection,true-negative,p-miss,p-fa,costDet"+"\n");
	     String line = "";
	     String cvsSplitBy = ",";
	     String[][] docLable=new String [DocNumebr][2];
	     int docRowId=0;
	        try (BufferedReader br = new BufferedReader(new FileReader(csvFile))) {
	        	
	        	br.readLine();//header ignored

	            while ((line = br.readLine()) != null) {
	            	
	                // use comma as separator
	                String[] currenDoc = line.split(cvsSplitBy);
	                docLable[docRowId][0]=currenDoc[3];//(3+1)th column is tag
	                docLable[docRowId][1]=(currenDoc[featureColumn]);//(4+1)th column is score
	                ++docRowId;

	            }

	        } catch (IOException e) {
	            e.printStackTrace();
	        }
	        
	     
	       String[] output = new String [DocNumebr];
	      double theta=0.0;
	      //  for (double theta=0;theta<=1;theta+=0.001)
	       while (theta<=1)
	        	{
	    	    theta=Double.parseDouble(df.format(theta));
	        	 docRowId=0;
	        	int a=0;//true positive
	        	int b=0;//False alarm
	        	int c=0;//miss
	        	int d=0;// true negative
	        	//System.out.println(theta);
	        		for (String[] thisdoc : docLable)
	    	        {
		        		
		        		if ((thisdoc[0]=="off-topic")| (thisdoc[0]=="tahlil"))
		        		{
							//make an output that make sense
			        		output[docRowId]="off-topic";
			        		docRowId++;
		        		}
			        	else
			        	{
			        		double score=1-(Double.parseDouble(thisdoc[1]));
			        		if (score<theta)
			        		{
			        			output[docRowId]="old";
			        		}
			        		else
			        		{
			        			output[docRowId]="new";
			        		}
			        		docRowId++;
			        	}
			        }
	        		
	        		
	        		for (int i=0;i<DocNumebr;++i)
	        		{
	        			if ((docLable[i][0]=="off-topic")| (docLable[i][0]=="tahlil"))
	        			{
	        				//do nothing
	        				continue;
	        				
	        			}
	        			else
	        			{
	        				if ((output[i].equals(docLable[i][0])) & (output[i].equals("new")))
	        				{
	        					++a;//true positive
	        				}
	        				
	        				if ((output[i].equals(docLable[i][0])) & (output[i].equals("old")))
	        				{
	        					++d; // true negative
	        				}
	        				
	        				if (((output[i].equals("old"))) & docLable[i][0].equals("new"))
	        				{
	        					++c;
	        					if (theta==0.71)// miss
	        					System.out.println("miss in row :"+i);
	        				}
	        				if (((output[i].equals("new"))) & docLable[i][0].equals("old"))
	        				{
	        					++b; // false alarm
	        					if (theta==0.71)
	        					System.out.println("false in row :"+i);
	        				}
	        			}
	        		}
	        		
	        		double pMiss=(double)((c))/(double)(a+c);
	        		double pFa= (double)b/(double)(b+d); 
	        		double cDet = (1*pMiss*0.02)+(0.1*pFa*0.98);
	        		//System.out.println(theta+","+a+","+b+","+c+","+d+","+pMiss+","+pFa);
	        		bw.write(theta+","+a+","+b+","+c+","+d+","+pMiss+","+pFa+","+cDet+"\n");
	        		theta+=0.001;
			     }
	       bw.close();
	        System.out.println("done");

	}

}
