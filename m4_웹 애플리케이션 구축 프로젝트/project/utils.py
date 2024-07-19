from models import Novels
import pandas as pd
from collections import Counter
from flask import jsonify
from models import db, Novels, Images, Publishers
from sqlalchemy import desc
import numpy as np

def get_data_from_form(form):
  genre_id = form.genre_id.data
  genre_name = form.genre_name.data
  keywords = form.keywords.data

  return genre_id, genre_name, keywords

def get_data_from_request(request):
  genre_id = request.form.get('genre_id')
  genre_name = request.form.get('genre_name')
  keywords = request.form.get('keywords')

  return genre_id, genre_name, keywords

# Novels 데이터프레임
def get_novels_to_dataframe(novels):
  data = []
  for novel in novels:
    novel_data = {
      'id': novel.id,
      'title': novel.title,
      'users_id': novel.users_id,
      'publisher_id': novel.publisher_id,
      'price': novel.price,
      'ing': novel.ing,
      'author': novel.author,
      'genre_id': novel.genre_id,
      'viewCount': novel.viewCount,
      'reviewCount': novel.reviewCount,
      'score': novel.score,
      'uploaded': novel.uploaded,
      'date': novel.date,
      'free_info': novel.free_info,
      'keywords': novel.keywords
    }
    data.append(novel_data)
  
  df = pd.DataFrame(data)

  return df
  
def format_count(count):
  if count >= 100000000:
    return f'{count / 100000000:.1f}억'
  elif count >= 10000:
    return f'{count / 10000:.0f}만'
  else:
    return f'{count:.0f}'

# 키워드로 소설 정보 가져오기
def get_novel_data_by_keywords(genre_id, keywords):
  novel_data = Novels.query.filter(
    Novels.genre_id == genre_id,
    *[Novels.keywords.contains(keyword) for keyword in keywords]
  ).all()

  if not novel_data:
    return None

  return novel_data

# 장르별 상위 10개 작품 가져오기
def novel_to_dict(novel):
  return {
    'id': novel.id,
    'title': novel.title,
    'users_id': novel.user.users,
    'publisher_id': novel.publisher.publisher,
    'price': novel.price,
    'ing': novel.ing,
    'author': novel.author,
    'genre_id': novel.genre_id,
    'viewCount': novel.viewCount,
    'reviewCount': novel.reviewCount,
    'score': novel.score,
    'uploaded': novel.uploaded,
    'date': novel.date.strftime('%Y-%m-%d'),
    'free_info': novel.free_info,
    'keywords': novel.keywords,
    'src':novel.images[0].src if novel.images else None,
    'revenue':(novel.price * novel.viewCount) * 0.778
  }

def get_top_10_novels(genre_id):
  novel_data = db.session.query(Novels).filter_by(genre_id=genre_id).order_by(
    desc((Novels.viewCount + Novels.reviewCount) / 2)
  ).limit(10).all()

  return novel_data

# 장르별 전체 소설 데이터 가져오기
def get_novels_by_genre(genre_id):
  novels = Novels.query.filter_by(genre_id=genre_id).all()

  return novels

# 소설 데이터의 모든 키워드 가져오기
def get_all_keywords(novels):
  df = get_novels_to_dataframe(novels)
  keywords_list = df['keywords'].to_list()
  all_keywords = [keyword for keywords in keywords_list for keyword in keywords]
  return all_keywords

def get_top_num_keywords(keywords, num=5):
  keyword_counts = Counter(keywords)
  top_num_keywords = keyword_counts.most_common(num)
  most_common_keyword = top_num_keywords[0][0] if top_num_keywords else None
  return top_num_keywords, most_common_keyword

# 장르별 선택 키워드 출연 비중
def get_keywords_importance(genre_id, selected_keywords):
  novels = get_novels_by_genre(genre_id)

  # 장르의 모든 소설을 기준으로
  all_keywords = get_all_keywords(novels)
  keyword_counts = Counter(all_keywords)

  selected_counts = {keyword: keyword_counts.get(keyword, 0) for keyword in selected_keywords}
  others_count = sum(count for keyword, count in keyword_counts.items() if keyword not in selected_keywords)

  data = {
    'selected': selected_counts,
    'others': others_count,
    'most_common_keyword' : max(selected_counts, key=selected_counts.get)
  }

  return data

# 장르별 상위 10개 키워드와 선택된 키워드 비교 라인 그래프
def get_top_10_keywords_by_genre(genre_id, selected_keywords):
  novels = get_novels_by_genre(genre_id)

  all_keywords = get_all_keywords(novels)
  keyword_counts = Counter(all_keywords)

  sorted_keywords = sorted(keyword_counts.items(), key=lambda item: item[1], reverse=True)
  top_keywords = sorted_keywords[:10]
  
  for keyword in selected_keywords:
    if keyword not in [kw for kw, count in top_keywords]:
      top_keywords.append((keyword, keyword_counts.get(keyword, 0)))
  
  return top_keywords

# 관련 소설이 0개일 때, 해당 장르 TOP 10의 최빈도 출판사, 평균 평점, 평균 뷰카운트, 평균 리뷰카운트
def get_top_10_novels_analysis(novels):

  df = get_novels_to_dataframe(novels)
  
  publisher_id = df['publisher_id'].mode()[0]
  most_common_publisher = Publishers.query.filter_by(id=publisher_id).first().publisher
    
  # 평균 평점
  avg_score = df['score'].mean()
  
  # 평균 viewCount
  avg_view_count = format_count(df['viewCount'].mean())
  
  # 평균 reviewCount
  avg_review_count = df['reviewCount'].mean()
  
  analysis = {
    'most_common_publisher': most_common_publisher,
    'avg_score': avg_score,
    'avg_view_count': avg_view_count,
    'avg_review_count': avg_review_count
  }
  
  return analysis

def get_novels_data_by_each_keyword(genre_id, keywords):
  results = []
  for keyword in keywords:
    novels = get_novel_data_by_keywords(genre_id, [keyword])
    if novels:
      df = get_novels_to_dataframe(novels)
      
      # 평균 수익
      df['revenue'] = (df['price'] * df['viewCount']) * 0.778
      avg_revenue = int(df['revenue'].mean())
      avg_revenue = format_count(avg_revenue)
      
      # 평균 평점
      avg_score = df['score'].mean()
      avg_score = round(df['score'].mean(), 1)
      
      # 가장 인기가 많은 작품
      most_popular_novel = df.loc[(df['viewCount'] + df['reviewCount']) / 2 == ((df['viewCount'] + df['reviewCount']) / 2).max()].iloc[0]
      
      # 가장 많이 등장한 출판사
      publisher_id = df['publisher_id'].mode()[0] if not df['publisher_id'].mode().empty else None
      most_common_publisher = Publishers.query.filter_by(id=publisher_id).first().publisher if publisher_id else None

      most_common_publishers = list(set([result['most_common_publisher'] for result in results if result['most_common_publisher']]))
      
      results.append({
        'keyword': keyword,
        'avg_revenue': avg_revenue,
        'avg_score': avg_score,
        'most_popular_novel': most_popular_novel.to_dict(),
        'most_common_publisher': most_common_publisher
      })
  return results, most_common_publishers

def get_avg_data_by_genre(genre_id):
  novels = get_novels_by_genre(genre_id)
  if not novels:
    return None

  df = get_novels_to_dataframe(novels)

  # 평균 평점 계산 (소수점 한 자리까지)
  avg_score = round(df['score'].mean(), 1)
  
  # 평균 조회수 및 리뷰수 계산 및 형식 변환
  avg_view_count = df['viewCount'].mean()
  avg_review_count = df['reviewCount'].mean()
  formatted_avg_view_count = avg_view_count
  formatted_avg_review_count = avg_review_count
  
  # 최빈도 출판사
  if not df['publisher_id'].mode().empty:
    publisher_id = df['publisher_id'].mode()[0]
    most_common_publisher = Publishers.query.filter_by(id=publisher_id).first().publisher
  else:
    most_common_publisher = None

  avg_data = {
    'avg_score': avg_score,
    'avg_view_count': formatted_avg_view_count,
    'avg_review_count': formatted_avg_review_count,
    'most_common_publisher': most_common_publisher
  }

  return avg_data

# 조회수 별 군집화 하여 평균 데이터 계산
def get_avg_data_by_viewcount_range(genre_id, view_count):
    novels = get_novels_by_genre(genre_id)
    if not novels:
        return None

    df = get_novels_to_dataframe(novels)
    
    ranges = [(0, 10000), (10000, 100000), (100000, 500000), (500000, 1000000),
              (1000000, 2000000), (2000000, 5000000), (5000000, 10000000), 
              (10000000, 20000000), (20000000, 50000000), (50000000, float('inf'))]

    selected_range = None
    for r in ranges:
        if r[0] <= view_count < r[1]:
            selected_range = r
            break

    if not selected_range:
        return None

    range_novels = df[(df['viewCount'] >= selected_range[0]) & (df['viewCount'] < selected_range[1])]
    
    avg_score = round(range_novels['score'].mean(), 1)
    avg_review_count = range_novels['reviewCount'].mean()
    formatted_avg_review_count = avg_review_count

    avg_data = {
        'avg_score': avg_score,
        'avg_review_count': formatted_avg_review_count
    }

    return avg_data

# 홈화면 상위 100개 작품 노출
def get_top100_novels(page, per_page):
  top_100_query = db.session.query(Novels).order_by(
    desc((Novels.viewCount + Novels.reviewCount) / 2)
  ).limit(100).subquery()

  pagination = db.session.query(Novels).filter(Novels.id.in_(db.session.query(top_100_query.c.id))).paginate(page=page, per_page=per_page, error_out=False)

  novels_data = []
  for novel in pagination.items:
    image = Images.query.filter_by(novel_id=novel.id).first()
    novel_data = {
      "id": novel.id,
      "title": novel.title,
      "author": novel.author,
      "viewCount": novel.viewCount,
      "src": image.src if image else None
    }
    novels_data.append(novel_data)

  return {
    'novels': novels_data,
    'total': pagination.total,
    'pages': pagination.pages,
    'current_page': pagination.page
  }

# 여러개 소설 dict화
def novels_to_dict(novels):
  novels_dict = []
  for novel in novels:
    data = {
      'id': novel.id,
      'title': novel.title,
      'users': novel.user.users,
      'publisher': novel.publisher.publisher,
      'price': novel.price,
      'ing': novel.ing,
      'author': novel.author,
      'viewCount': novel.viewCount,
      'reviewCount': novel.reviewCount,
      'score': novel.score,
      'date': novel.date.strftime('%Y'),
      'keywords': novel.keywords,
      'src': novel.images[0].src if novel.images else None,
      'revenue': (novel.price * novel.viewCount) * 0.778,
      'popularity': (novel.viewCount + novel.reviewCount) / 2
    }
    novels_dict.append(data)

  novels_dict_sorted = sorted(novels_dict, key=lambda x: x['popularity'], reverse=True)

  return novels_dict_sorted
