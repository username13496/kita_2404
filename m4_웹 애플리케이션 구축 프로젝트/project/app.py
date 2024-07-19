from flask import Flask, render_template, request, jsonify, redirect, url_for, flash, session
from flask_wtf.csrf import CSRFProtect
from flask_migrate import Migrate
from models import db, Keyword, Genre, Customer
from werkzeug.security import generate_password_hash, check_password_hash
from form import LoginForm, RegistrationForm, DebutForm
from utils import *
import logging
import json

app = Flask(__name__)
app.config.from_pyfile("config.py")

db.init_app(app)

migrate = Migrate(app, db)
csrf = CSRFProtect(app)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 첫 요청을 추적하기 위한 플래그
first_request = True

@app.before_request
def create_admin():
  global first_request
  if first_request:
    with app.app_context():
      if not Customer.query.filter_by(customername="admin").first():
        admin = Customer(customername="admin", is_admin=True)
        admin.password = generate_password_hash("admin", method='sha256')
        db.session.add(admin)
        db.session.commit()
    first_request = False

@app.route('/')
def home():
  page = request.args.get('page', 1, type=int)
  per_page = 18
  novels_data = get_top100_novels(page, per_page)
  
  start_page = max(1, page - 3)
  end_page = min(novels_data['pages'], page + 2)
  
  return render_template(
    'home.html', 
    novels=novels_data['novels'], 
    pages=novels_data['pages'], 
    current_page=novels_data['current_page'],
    start_page=start_page,
    end_page=end_page
  )

@app.route('/guide')
def guide():
  
  return render_template('guide.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
  form = RegistrationForm()
  if form.validate_on_submit():
    existing_customer = Customer.query.filter_by(customername=form.customername.data).first()
    if existing_customer:
      flash("Customername already exists. Please choose a different customername.", "danger")
      return render_template("register.html", form=form)
    hashed_password = generate_password_hash(form.password.data, method='scrypt')
    new_customer = Customer(customername=form.customername.data, password=hashed_password, is_admin=form.is_admin.data)
    db.session.add(new_customer)
    db.session.commit()
    flash('Registration successful. You can now log in.', 'success')
    return redirect(url_for('login'))
  return render_template('auth/register.html', form=form)

@app.route('/login', methods=['GET', 'POST'])
def login():
  if "customer_id" in session:
    return redirect(url_for('home'))

  form = LoginForm()
  if form.validate_on_submit():
    customer = Customer.query.filter_by(customername=form.customername.data).first()
    if customer and check_password_hash(customer.password, form.password.data):
      session['customer_id'] = customer.id
      session['customername'] = customer.customername
      session['is_admin'] = customer.is_admin
      flash('Login successful.', 'success')
      return redirect(url_for('home'))
    flash("Invalid customername or password.", 'danger')
  return render_template('auth/login.html', form=form)

@app.route('/logout')
def logout():
  if "customer_id" not in session:
    return redirect(url_for('login'))

  session.clear()
  flash('You have been logged out.', 'success')
  return redirect(url_for('login'))
  
# 키워드 매칭 파트
@app.route('/debut', methods=['GET', 'POST'])
def debut():
  if "customer_id" not in session:
    return redirect(url_for('login'))
  
  form = DebutForm()
  genres = Genre.query.all()

  if form.validate_on_submit():
    genre_id, genre_name, keywords = get_data_from_form(form)

    return redirect(url_for('debut_analysis', genre_id=genre_id, genre_name=genre_name, keywords=','.join(keywords)))

  return render_template('debuts/debut.html', form=form, genres=genres)
  
# 상세 분석 정보 파트
@app.route('/debut/analysis', methods=['GET', 'POST'])
def debut_analysis():
  if "customer_id" not in session:
    return redirect(url_for('login'))

  genre_id, genre_name, keywords = get_data_from_request(request)
  novel_data = get_novel_data_by_keywords(genre_id, keywords)
  keywords = keywords.split(',')

  # 장르 인기 키워드와 선택 키워드 비교
  keywords_rank = get_top_10_keywords_by_genre(genre_id, keywords)
  # 선택한 키워드의 장르내 비중
  keywords_importance = get_keywords_importance(genre_id, keywords) or []

  # 상위 10개 소설 키워드 가져오기 - 그중 최빈도수 5개 가져오기
  top_10_novels = get_top_10_novels(genre_id)
  top_novels_keywords = get_all_keywords(top_10_novels)
  top_5_keywords, top_5_mck = get_top_num_keywords(top_novels_keywords, num=5)

  # 선택한 키워드별 인기 작품 및 평균 데이터
  each_keywords, most_common_publishers = get_novels_data_by_each_keyword(genre_id, keywords)
  analysis = get_top_10_novels_analysis(top_10_novels)
  most_common_keyword_rank = next((index + 1 for index, (kw, count) in enumerate(keywords_rank) if kw == keywords_importance['most_common_keyword']), None)
  top_5_mck_rank = next((index + 1 for index, (kw, count) in enumerate(keywords_rank) if kw == top_5_mck), None)
  avg_data = get_avg_data_by_genre(genre_id)

  data = {
    'top_10_novels': top_10_novels,
    'genre_id': genre_id,
    'genre_name': genre_name,
    'keywords': keywords,
    'keywords_rank': keywords_rank,
    'keywords_importance': keywords_importance,
    'top_5_keywords': top_5_keywords,
    'top_5_mck':top_5_mck,
    'each_keywords':each_keywords, 
    'analysis':analysis, 
    'most_common_publishers':most_common_publishers,
    'most_common_keyword':keywords_importance['most_common_keyword'],
    'most_common_keyword_rank':most_common_keyword_rank,
    'top_5_mck_rank':top_5_mck_rank,
    'avg_data':avg_data
  }
  
  # novel이 0개일 때
  if not novel_data:
    flash("선택하신 키워드 관련 소설이 존재하지 않습니다. 카테고리를 제외한 분석 결과를 제공합니다", "info")
    return render_template('debuts/novel_not_found.html', data=data)

  # novel이 1개일 때
  if len(novel_data) == 1:
    novel = novel_data[0]
    data['novel'] = novel_to_dict(novel)

    #조회수 별 군집화하여 평균 데이터 가져오기
    avg_data_by_range = get_avg_data_by_viewcount_range(genre_id, novel.viewCount)

    flash("선택하신 키워드 관련 소설이 1개 존재합니다. 해당 작품의 분석 결과만 제공됩니다", "info")
    return render_template('debuts/debut_analysis_single.html',
      data=data, avg_data_by_range=avg_data_by_range)

  # novel이 2개 이상일 때
  novels = novels_to_dict(novel_data)
  data['novels'] = novels
  novels_json = json.dumps(novels)
  
  return render_template('debuts/debut_analysis.html', data=data, novels_json=novels_json)

@app.route('/publishers', methods=['GET', 'POST'])
def publishers():
  if "customer_id" not in session:
    return redirect(url_for('auth/login'))
  
  return render_template('publishers.html')

@app.route('/publishers/analysis', methods=['GET', 'POST'])
def publisher_analysis():
  if "customer_id" not in session:
    return redirect(url_for('login'))
  
  return render_template('analysis/publishers_analysis.html')
  
@app.route('/million_analysis')
def million_analysis():
  if "customer_id" not in session:
    return redirect(url_for('login'))
  
  return render_template('analysis/million_analysis.html')
  
@app.route('/genre_analysis/<genre_id>')
def genre_analysis():
  if "customer_id" not in session:
    return redirect(url_for('login'))

  return render_template('analysis/genre_analysis.html')

@app.route('/community')
def community():
  
  return render_template('community.html')

@app.route('/notices')
def notices():
  
  return render_template('notices.html')

@app.route('/get_keywords/<genre_id>', methods=['GET'])
def get_keywords(genre_id):
  if "customer_id" not in session:
    return redirect(url_for('login'))
  
  keywords = Keyword.query.filter_by(genre_id=genre_id).all()
  keywords_list = [{'id': k.id, 'keyword': k.keyword} for k in keywords]
  return jsonify(keywords_list)

if __name__ == '__main__':
  app.run(debug=True, port=5001, use_reloader=False)
