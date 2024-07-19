from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Customer(db.Model):
  __tablename__ = 'customers'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  customername = db.Column(db.String(80), unique=True, nullable=False)
  password = db.Column(db.String(200), nullable=False)
  is_admin = db.Column(db.Boolean, default=False)

  def __repr__(self):
    return f'<Genre {self.genre}>'

class Keyword(db.Model):
  __tablename__ = 'keywords'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  keyword = db.Column(db.String(100), nullable=False)
  genre_id = db.Column(db.Integer, db.ForeignKey('genre.id'), nullable=False)

  def __repr__(self):
    return f'<Keyword {self.keyword}>'

class Users(db.Model):
  __tablename__ = 'users'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  users = db.Column(db.String(100), nullable=False)
  novels = db.relationship('Novels', backref='user', lazy=True)

class Publishers(db.Model):
  __tablename__ = 'publishers'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  publisher = db.Column(db.String(100), nullable=False)
  novels = db.relationship('Novels', backref='publisher', lazy=True)

class Genre(db.Model):
  __tablename__ = 'genre'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  genre = db.Column(db.String(100), nullable=False)
  novels = db.relationship('Novels', backref='genre', lazy=True)

class Images(db.Model):
  __tablename__ = 'images'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  src = db.Column(db.String(255), nullable=False)
  novel_id = db.Column(db.Integer, db.ForeignKey('novels.id'), nullable=False)

  novel = db.relationship('Novels', backref=db.backref('images', lazy=True))

  def __repr__(self):
      return f'<Image {self.src}>'
  
class Novels(db.Model):
  __tablename__ = 'novels'
  __table_args__ = {'extend_existing': True}
  id = db.Column(db.Integer, primary_key=True)
  title = db.Column(db.String(255), nullable=False)
  users_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
  publisher_id = db.Column(db.Integer, db.ForeignKey('publishers.id'), nullable=False)
  price = db.Column(db.Integer, nullable=False)
  ing = db.Column(db.String(50), nullable=False)
  author = db.Column(db.String(100), nullable=False)
  genre_id = db.Column(db.Integer, db.ForeignKey('genre.id'), nullable=False)
  viewCount = db.Column(db.Integer, nullable=False)
  reviewCount = db.Column(db.Integer, nullable=False)
  score = db.Column(db.Float, nullable=False)
  uploaded = db.Column(db.Integer, nullable=False)
  date = db.Column(db.Date, nullable=False)
  free_info = db.Column(db.Integer, nullable=False)
  keywords = db.Column(db.JSON, nullable=False)

  def __repr__(self):
    return f'<Novel {self.title} by {self.author}>'