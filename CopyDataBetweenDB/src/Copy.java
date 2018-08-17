import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.HashMap;

public class Copy {
	public static void main(String[] args) throws Exception {
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		BufferedReader br = new BufferedReader(new FileReader(new File("OldNewPlain.txt")));
		String line;
		HashMap<Integer, String> agencyID = new HashMap<>();
		int counter = 0;
		while ((line = br.readLine()) != null) {
			String[] tmp = line.split("\t");
			agencyID.put(counter++, tmp[0]);
			System.out.println(tmp[0]);
		}
		br.close();
		Connection conn = DriverManager.getConnection(
				"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=tabnak;integratedSecurity=true");
		System.out.println("connection get for tabnak");
		Connection conn2 = DriverManager.getConnection(
				"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=rigi;integratedSecurity=true");
		System.out.println("connection get for rigi");
		PreparedStatement statement = conn.prepareStatement("select * from khabar where id = ?");
		PreparedStatement statementInsert = conn2.prepareStatement("INSERT INTO khabar VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
		
		for (int i =0;i<agencyID.size();++i)
		{
			String[] agency_id = agencyID.get(i).split("-");
			
			if (agency_id[0].contains("tabnak"))
			{
				
				statement.setInt(1, Integer.parseInt(agency_id[1]));
				ResultSet rs = statement.executeQuery();
				//while (rs.next())
			//	{
				//	System.out.println(rs.getInt(1));
				//}
				rs.next();
				statementInsert.setString(1, "tabnak");
				statementInsert.setInt(2, rs.getInt(1));
				statementInsert.setString(3, rs.getString(2));
				statementInsert.setString(4, rs.getString(3));
				statementInsert.setString(5, rs.getString(4));
				statementInsert.setString(6, rs.getString(5));
				statementInsert.setInt(7, rs.getInt(6));
				statementInsert.setString(8, rs.getString(7));
				statementInsert.setInt(9, rs.getInt(8));
				statementInsert.setInt(10, rs.getInt(9));
				statementInsert.setInt(11, rs.getInt(10));
				statementInsert.setInt(12, rs.getInt(11));
				statementInsert.setInt(13, rs.getInt(12));
				statementInsert.setInt(14, rs.getInt(13));
				statementInsert.setInt(15, rs.getInt(14));
				statementInsert.setInt(16, rs.getInt(15));
				statementInsert.setString(17, "");
				statementInsert.addBatch();
				
			}
		}
		System.out.println("tabnak done");
		conn.close();
		Connection connKhabarOnline = DriverManager.getConnection(
					"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=khabaronline;integratedSecurity=true");
		 System.out.println("connection get for khabaronline");
		 PreparedStatement statementKhabarOnline = connKhabarOnline.prepareStatement("select * from khabar where id = ?");
		for (int i =0;i<agencyID.size();++i)
		{
			String[] agency_id = agencyID.get(i).split("-");
			
			if (agency_id[0].contains("khabaronline"))
			{
				
//				statementKhabarOnline.setBigDecimal(1, BigDecimal.valueOf(Integer.parseInt(agency_id[1])).movePointLeft(2));//;(1, Integer.parseInt(agency_id[1]));
//				ResultSet rs = statementKhabarOnline.executeQuery();
//				while (rs.next())
//				{
//					System.out.println(rs.getBigDecimal(1));
//				}
				statementKhabarOnline.setInt(1, Integer.parseInt(agency_id[1]));
				ResultSet rs = statementKhabarOnline.executeQuery();
				rs.next();
				statementInsert.setString(1, "khabaronline");
				statementInsert.setInt(2, rs.getInt(1));
				statementInsert.setString(3, rs.getString(2));
				statementInsert.setString(4, rs.getString(3));
				statementInsert.setString(5, rs.getString(4));
				statementInsert.setString(6, rs.getString(5));
				statementInsert.setInt(7, rs.getInt(6));
				statementInsert.setString(8, rs.getString(7));
				statementInsert.setInt(9, rs.getInt(8));
				statementInsert.setInt(10, rs.getInt(9));
				statementInsert.setInt(11, rs.getInt(10));
				statementInsert.setInt(12, rs.getInt(11));
				statementInsert.setInt(13, rs.getInt(12));
				statementInsert.setInt(14, rs.getInt(13));
				statementInsert.setInt(15, rs.getInt(14));
				statementInsert.setInt(16, rs.getInt(15));
				statementInsert.setString(17, "");
				statementInsert.addBatch();
				
			}
		}
		
		System.out.println("khabaronline done");
		//conn.close();*/
		 Connection conn3 = DriverManager.getConnection(
					"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=Fardanews;integratedSecurity=true");
		 PreparedStatement statement2 = conn3.prepareStatement("select * from khabar where id = ?");
		 System.out.println("connection get for FardaNews");
		for (int i =0;i<agencyID.size();++i)
		{
			String[] agency_id = agencyID.get(i).split("-");
			
			if (agency_id[0].contains("fardaNews"))
			{
				
				statement2.setInt(1, Integer.parseInt(agency_id[1]));
				ResultSet rs = statement2.executeQuery();
				rs.next();
				statementInsert.setString(1, "fardaNews");
				statementInsert.setInt(2, rs.getInt(1));
				statementInsert.setString(3, rs.getString(2));
				statementInsert.setString(4, rs.getString(3));
				statementInsert.setString(5, rs.getString(4));
				statementInsert.setString(6, rs.getString(5));
				statementInsert.setInt(7, rs.getInt(6));
				statementInsert.setString(8, rs.getString(7));
				statementInsert.setInt(9, rs.getInt(8));
				statementInsert.setInt(10, rs.getInt(9));
				statementInsert.setInt(11, rs.getInt(10));
				statementInsert.setInt(12, rs.getInt(11));
				statementInsert.setInt(13, rs.getInt(12));
				statementInsert.setInt(14, rs.getInt(13));
				statementInsert.setInt(15, rs.getInt(14));
				statementInsert.setInt(16, rs.getInt(15));
				statementInsert.setString(17, "");
				statementInsert.addBatch();
				
			}
		}
		System.out.println("khabaronline done");
		//conn.close();
		int[] inserResult = statementInsert.executeBatch();
		System.out.println("insert result:");
		System.out.println(Arrays.toString(inserResult));
		conn2.close();
		System.out.println("done");
	}
}
