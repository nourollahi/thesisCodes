import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import java.util.Properties;
import java.util.Scanner;

import com.persianp.nlp.process.Process;
import com.persianp.nlp.process.Token;

public class commentFetcherFromDB {
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
		Properties properties = new Properties();
		properties.load(commentFetcherFromDB.class.getResourceAsStream("persianp.properties"));
		Process process = new Process(properties);
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Connection conn = DriverManager.getConnection(
				"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=ghatl_dadashi;integratedSecurity=true");
		 Scanner scanner = new Scanner(new File("FBDOCS.csv"));
		 scanner.next();
		 BufferedWriter bw = new BufferedWriter(new FileWriter("output/outputText-Test.txt"));
	        while(scanner.hasNext()){
	        	String[] line = scanner.next().split(",");
	        	if (Integer.parseInt(line[3])>0)
	        	{
	        		String tableName = "all"+line[2].toLowerCase()+"comments";
	        		System.out.println(tableName);
	        		String Sql = "select contents from "+tableName+" where idKhabar = ?";
	        		PreparedStatement preparedStatement = conn.prepareStatement(Sql);
	    			//preparedStatement.setString(1, "all-"+line[2]+"-comments");
	    			preparedStatement.setString(1, line[0]);
	    			ResultSet rs = preparedStatement.executeQuery();
	    			int docCounter = 0;
	    			while (rs.next()) {
	    					String comment = rs.getString("contents");
	    					process.process(comment);
	    					List<Token> tokens = process.getNonStopwordTokens();
	    					StringBuilder sb = new StringBuilder();
	    					for (Token token : tokens) {
	    						if ((!(token.getTag().equals("PUNC"))) & token.getText().length()<20 & !(token.getTag().equals("RES"))) {
	    							sb.append(token.getText()+" ");
	    						}
							}
	    					bw.write("<DOC>"+"\n");
	    					bw.write("<DOCNO>FB_"+line[0]+"_"+line[1]+"_"+docCounter+++"</DOCNO>"+"\n");
	    					bw.write("<TEXT>"+"\n");
	    					//System.out.println(sb.toString());
	    					String tmpText = sb.toString().trim().replace("ی", "ي");
	    					//System.out.println(tmpText);
							bw.write(tmpText+"\n");
							bw.write("</TEXT>"+"\n");
							bw.write("</DOC>"+"\n");
	    				}
	    		 
	        	}
	        	System.out.println(line[0]+" done.");
	        }
	        scanner.close();
	        
	        //writing collection documents
	        int docID = 0;
	    	String Sql = "select contents from allfardanewscomments";
    		PreparedStatement preparedStatement = conn.prepareStatement(Sql);
			ResultSet rs = preparedStatement.executeQuery();
			while (rs.next()) {
					String comment = rs.getString("contents");
					bw.write("<DOC>"+"\n");
					bw.write("<DOCNO>background_"+docID+++"</DOCNO>"+"\n");
					bw.write("<TEXT>"+"\n");
					bw.write(comment+"\n");
					bw.write("</TEXT>"+"\n");
					bw.write("</DOC>"+"\n");
				}
			System.out.println("1 of 3 done");
			
			 Sql = "select contents from alltabnakcomments";
    		 preparedStatement = conn.prepareStatement(Sql);
			 rs = preparedStatement.executeQuery();
			while (rs.next()) {
					String comment = rs.getString("contents");
					bw.write("<DOC>"+"\n");
					bw.write("<DOCNO>background_"+docID+++"</DOCNO>"+"\n");
					bw.write("<TEXT>"+"\n");
					bw.write(comment+"\n");
					bw.write("</TEXT>"+"\n");
					bw.write("</DOC>"+"\n");
				}
			System.out.println("2 of 3 done");
			 Sql = "select contents from allkhabaronlinecomments";
    		 preparedStatement = conn.prepareStatement(Sql);
			 rs = preparedStatement.executeQuery();
			while (rs.next()) {
					String comment = rs.getString("contents");
					bw.write("<DOC>"+"\n");
					bw.write("<DOCNO>background_"+docID+++"</DOCNO>"+"\n");
					bw.write("<TEXT>"+"\n");
					bw.write(comment+"\n");
					bw.write("</TEXT>"+"\n");
					bw.write("</DOC>"+"\n");
				}
			System.out.println("3 of 3 done");
	        bw.close();
	}
}
