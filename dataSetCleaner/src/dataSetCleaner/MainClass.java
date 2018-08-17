package dataSetCleaner;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;




public class MainClass {
	//static ArrayList<String> uniqueListbasic = new ArrayList<String>();
	//static ArrayList<String> uniqueListR = new ArrayList<String>();

	public static void main(String[] args) throws IOException {
		
	
		BufferedReader bufferedReader1 = new BufferedReader(new FileReader(new File("webkb.txt")));
		HashSet<String> uniqueWordsbasichash = new HashSet<String>();
		String wordss;
		while ((wordss=bufferedReader1.readLine())!=null)
		{
		String[] words = wordss.split(" ");
		

		for (String word : words) {
			uniqueWordsbasichash.add(word);
		}
		}
		System.out.println("basic unique worde="+uniqueWordsbasichash.size());
		/////
		// uniqueListbasic = new ArrayList<String>(uniqueWordsbasichash);
		/////////////////////////////////////////////////////////////////////////////////////////////////////////
		bufferedReader1.close();
		
		///////////////
		HashSet<String> uniqueWordhashR = new HashSet<String>();
		BufferedReader bufferedReader2 = new BufferedReader(new FileReader(new File("webkb-InR.txt")));
		while ((wordss=bufferedReader2.readLine())!=null)
		{
		
			uniqueWordhashR.add(wordss);
		}
	
	 /////////////////////////////////////////////////////////////////////////////uniqueListR = new ArrayList<String>(uniqueWordhashR);
		System.out.println("R unique worde="+uniqueWordhashR.size());
		
		//intersection
		
//		List<Integer> intersection = new ArrayList<Integer> (uniqueListR.size() > uniqueListbasic.size() ?uniqueListR.size():uniqueListbasic.size());
//		intersection.addAll((List)uniqueListR);
//		intersection.retainAll(uniqueListbasic);
		
		
		//a-b
		List<String> c = new ArrayList<String> (uniqueWordsbasichash.size());

		c.addAll(uniqueWordsbasichash);
		c.removeAll(uniqueWordhashR);
		c.remove(0);
	System.out.println("final set size= "+c.size());
	
	// the words you want to remove from the file:
    //
   // Set<String> wordsToRemove = ImmutableSet.of("a", "for");

    // this code will run in a loop reading one line after another from the file
    //
	BufferedReader bufferedReader3 = new BufferedReader(new FileReader(new File("webkb.txt")));
	//HashSet<String> uniqueWordsLda = new HashSet<String>();
	String wordsss;
	 
	

	try{
	    PrintWriter writer = new PrintWriter("webkbcleaned.txt", "UTF-8");
	    
	    while ((wordsss=bufferedReader3.readLine())!=null)
		{
		String[] words = wordsss.split(" ");
		StringBuffer outputLine = new StringBuffer();

		for (String word : words) {
		   // uniqueWordsLda.add(word);
			  if (uniqueWordhashR.contains(word)) 
		        {
		            if (outputLine.length() > 0)
		            {
		                outputLine.append(" ");
		            }
		            outputLine.append(word);
		        }
		}
		writer.println(outputLine.toString());
		}
	    
	    writer.close();
	} catch (IOException e) {
	   // do something
	}
    
	
	}
	
	
}
