package commentAgreegator;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class Main {
	
	public static void main(String[] args) throws IOException {
		BufferedReader news = new BufferedReader(new FileReader(new File("input/sortedNews.txt")));
		
		BufferedWriter output = new BufferedWriter(new FileWriter(new File("output/sortedComment-utf8.txt")));
		String line;
		int i=0;
		while ((line = news.readLine()) != null)
		{
		
			String[] khabarStringArray=line.split("\t");
			String khabarID = khabarStringArray[0];
			String temp;
			BufferedReader comments = new BufferedReader(new FileReader(new File("input/all-comment.txt")));
			while ((temp=comments.readLine())!=null)
			{
				String[] commentKhabarStringArray=temp.split("\t");
				String CommnetKhabarID = commentKhabarStringArray[0];
				if (CommnetKhabarID.equals(khabarID))
				{
					output.write(temp);
					output.write("\n");
				}
			}
			System.out.println(++i);
			comments.close();
		}
		output.close();
		news.close();
		
		System.err.println("Done");
	}

}
