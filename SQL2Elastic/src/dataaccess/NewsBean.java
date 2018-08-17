package dataaccess;

public class NewsBean {
	private int id;
	private String titr;
	private String content;
	private int countComment;
	private int year;
	private int month;
	private int day;
	private int hour;
	private int minute;

	public NewsBean(int id, String titr, String content, int countComment, int year, int month, int day,
			int hour, int minute) {
		
		this.id = id;
		this.titr = titr;
		this.content = content;
		this.countComment = countComment;
		this.year = year;
		this.month = month;
		this.day = day;
		this.hour = hour;
		this.minute = minute;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getTitr() {
		return titr;
	}

	public void setTitr(String titr) {
		this.titr = titr;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public int getCountComment() {
		return countComment;
	}

	public void setCountComment(int countComment) {
		this.countComment = countComment;
	}

	public int getYear() {
		return year;
	}

	public void setYear(short year) {
		this.year = year;
	}

	public int getMonth() {
		return month;
	}

	public void setMonth(short month) {
		this.month = month;
	}

	public int getDay() {
		return day;
	}

	public void setDay(short day) {
		this.day = day;
	}

	public int getHour() {
		return hour;
	}

	public void setHour(short hour) {
		this.hour = hour;
	}

	public int getMinute() {
		return minute;
	}

	public void setMinute(short minute) {
		this.minute = minute;
	}



}
