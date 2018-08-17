package ir.mostafa.thesis.database.fecher.news;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class NewsFetcher {
	public static void main(String[] args) throws Exception {
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File("output/tabnak-all-news.txt")));
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Connection conn = DriverManager
				.getConnection("jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=tabnak;integratedSecurity=true");
		Statement sta = conn.createStatement();
		String Sql = "select * from khabar";
		ResultSet rs = sta.executeQuery(Sql);
		System.out.println("rs loaded");
		while (rs.next()) {
			String khabarContent = rs.getString("content");
			bw.write(khabarContent.replace("\n", "").replace("\r", "") + "\n");
		}
		rs.close();
		conn.close();
		sta.close();
		bw.close();
		System.out.println("done");
	}
}
